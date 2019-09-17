//
//  AddCategoryCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import IQKeyboardManagerSwift

class AddCategoryCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let addCategoryViewController = AddCategoryViewController.initFromStoryboard()
        let addCategoryViewModel = AddCategoryViewModel()
        addCategoryViewController.viewModel = addCategoryViewModel
        IQKeyboardManager.shared.enable = true
        
        navigationController.pushViewController(addCategoryViewController, animated: true)
        
        addCategoryViewModel.backTapped
            .subscribe(onNext: { _ in
                print("dsadsad")
            })
            .disposed(by: disposeBag)
        
        return .never()
    }
}
