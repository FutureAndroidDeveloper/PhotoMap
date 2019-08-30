//
//  TimelineCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class TimelineCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let timelineViewController = TimelineViewController.initFromStoryboard(name: "Main")
        let viewModel = TimelineViewModel()
        timelineViewController.viewModel = viewModel
        navigationController.pushViewController(timelineViewController, animated: true)
        
        viewModel.categoriesTapped
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showCategoriesViewController(on: timelineViewController)
            }
            .subscribe(onNext: { })
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    private func showCategoriesViewController(on rootViewController: UIViewController) -> Observable<Void> {
        let categoriesCoordinator = CategoriesCoordinator(rootViewController: rootViewController)
        return coordinate(to: categoriesCoordinator)
    }
}
