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

        
        let signUp = viewModel.signUp.flatMap { self.showSignUpViewController() }
        let signIn = viewModel.signIn
        
        return Observable.merge(signUp, signIn)
            .do(onNext: { _ in
                IQKeyboardManager.shared.enable = false
                IQKeyboardManager.shared.enableAutoToolbar = false
                self.navigationController.dismiss(animated: true)
                authController.dismiss(animated: true)
            })
    }
    
    private func showSignUpViewController() -> Observable<Void> {
        let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        return coordinate(to: signUpCoordinator)
    }
}
