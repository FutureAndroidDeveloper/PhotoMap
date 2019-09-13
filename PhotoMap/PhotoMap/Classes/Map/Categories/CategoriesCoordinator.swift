//
//  CategoriesCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/28/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class CategoriesCoordinator: BaseCoordinator<Void> {
    private let rootViewController: UIViewController
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<Void> {
        let categoriesViewController = CategoriesViewController.initFromStoryboard()
        let viewModel = CategoriesViewModel()
        categoriesViewController.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: categoriesViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
        
        viewModel.addCategoryTapped
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showAddCaegoryViewController(in: navigationController)
            }
            .subscribe(onNext: { _ in
                print("END")
            })
            .disposed(by: disposeBag)
        
        return viewModel.didCancel
            .take(1)
            .do(onNext: { [weak self] categories in
                guard let self = self else { return }
                self.rootViewController.dismiss(animated: true, completion: nil)
            })
    }
    
    private func showAddCaegoryViewController(in navigationController: UINavigationController) -> Observable<Void> {
        let addCategoryCoordinator = AddCategoryCoordinator(navigationController: navigationController)
        return coordinate(to: addCategoryCoordinator)
    }
}
