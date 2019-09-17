//
//  AppCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import RxFirebase
import CodableFirebase

class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    let state: Observable<User?>
    
    init(window: UIWindow) {
        self.window = window
        state = Auth.auth().rx.stateDidChange.share(replay: 1)
    }
    
    override func start() -> Observable<Void> {
        // Applications are expected to have a root view controller at the end of application launch
        window.rootViewController = UINavigationController()

        do {
            try Auth.auth().signOut()
        } catch {}
        
        state
            .compactMap { $0 }
            .flatMap { [weak self] user -> Observable<Void> in
                guard let self = self else { return .empty() }
                self.checkForAdmin(user)
                let tabBarCoordinator = TabBarCoordinator(window: self.window)
                return self.coordinate(to: tabBarCoordinator)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        state
            .filter { $0 == nil }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let authCoordinator = AuthenticationCoordinator(window: self.window)
                return self.coordinate(to: authCoordinator)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func checkForAdmin(_ user: User) {
        let databaseRef = Database.database().reference().child("users").child(user.uid)
        databaseRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else { return }
            
            // TODO: - Handle Error
            do {
                let appUser = try FirebaseDecoder().decode(ApplicationUser.self, from: value)
                // set user privilege to AppDelegate
                (UIApplication.shared.delegate as! AppDelegate).isAdmin = appUser.isAdmin
            } catch let error {
                print(error)
            }
        })
    }
}
