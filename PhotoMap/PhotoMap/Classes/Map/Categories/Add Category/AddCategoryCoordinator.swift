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
        
        let result = navigationController.rx.willShow.asControlEvent()
            .compactMap { $0.viewController as? CategoriesViewController  }
            .map { _ in Void() }
            .take(1)
        
        return result.take(1)
    }
}
