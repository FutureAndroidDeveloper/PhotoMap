//
//  SignUpCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift

class SignUpCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let signUpViewController = SignUpViewController.initFromStoryboard(name: "Main")
        let viewModel = SignUpViewModel()
        signUpViewController.viewModel = viewModel
 
        navigationController.pushViewController(signUpViewController, animated: true)
        
        return viewModel.disappear.amb(viewModel.create)
            .take(1)
            .do(onNext: { _ in
                self.navigationController.isNavigationBarHidden = true
                self.navigationController.popToRootViewController(animated: true)
                signUpViewController.dismiss(animated: true)
            })
    }
}
