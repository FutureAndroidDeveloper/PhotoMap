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

//        do {
//            try Auth.auth().signOut()
//        } catch { }
        
        state
            .compactMap { $0 }
            .flatMap { _ -> Observable<Void> in
                let tabBarCoordinator = TabBarCoordinator(window: self.window)
                return self.coordinate(to: tabBarCoordinator)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        state
            .filter { $0 == nil }
            .flatMap { _ -> Observable<Void> in
                let authCoordinator = AuthenticationCoordinator(window: self.window)
                return self.coordinate(to: authCoordinator)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
}
