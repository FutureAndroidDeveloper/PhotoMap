//
//  SignUpCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift

enum SignUpCoordinatorResult {
    case created(Bool)
    case back
}

class SignUpCoordinator: BaseCoordinator<SignUpCoordinatorResult> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<CoordinatorResult> {
        let signUpViewController = SignUpViewController.initFromStoryboard()
        let viewModel = SignUpViewModel()
        signUpViewController.viewModel = viewModel
 
        navigationController.pushViewController(signUpViewController, animated: true)
        
        let back = viewModel.disappear.take(1).map { SignUpCoordinatorResult.back }
        let created = viewModel.create.take(1).map { SignUpCoordinatorResult.created(true) }
        let result = Observable.merge(back, created).share(replay: 1)

        return result
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController.isNavigationBarHidden = true
                self.navigationController.popToRootViewController(animated: true)
                signUpViewController.dismiss(animated: true)
            })
    }
}
