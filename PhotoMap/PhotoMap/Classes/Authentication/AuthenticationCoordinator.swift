//
//  AuthenticationCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/14/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import IQKeyboardManagerSwift

class AuthenticationCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow) {
        self.window = window
        navigationController = window.rootViewController as! UINavigationController
        navigationController.isNavigationBarHidden = true
        IQKeyboardManager.shared.enable = true
    }
    override func start() -> Observable<Void> {
        let authController = AuthenticationViewController.initFromStoryboard(name: "Main")
        let viewModel = AuthenticationViewModel()
        authController.viewModel = viewModel
        
        navigationController.pushViewController(authController, animated: true)
        window.makeKeyAndVisible()

        let signUp = viewModel.signUp.flatMap { [weak self] _ -> Observable<Bool?> in
            guard let self = self else { return .empty() }
            return self.showSignUpViewController()
        }
            .filter { $0 != nil }
            .map { _ in return Void() }
        
        let signIn = viewModel.signIn
        
        return Observable.merge(signUp, signIn)
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                IQKeyboardManager.shared.enable = false
                IQKeyboardManager.shared.enableAutoToolbar = false
                self.navigationController.dismiss(animated: true)
            })
    }
    
    private func showSignUpViewController() -> Observable<Bool?> {
        let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
        return coordinate(to: signUpCoordinator)
            .map { result in
                switch result {
                case .created(let flag): return flag
                case .back: return nil
                }
        }
    }
}
