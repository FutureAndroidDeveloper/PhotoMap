//
//  TabBarCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TabBarCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        // Setup NavigationControlles
        let mapNavigation = UINavigationController()
        mapNavigation.isNavigationBarHidden = true
        mapNavigation.navigationBar.tintColor = .white
        mapNavigation.tabBarItem = UITabBarItem(title: R.string.localizable.map(),
                                                image: R.image.tabBarItems.compass(),
                                                selectedImage: nil)
        
        let timelineNavigation = UINavigationController()
        timelineNavigation.tabBarItem = UITabBarItem(title: R.string.localizable.timeline(),
                                                     image: R.image.tabBarItems.timeline(),
                                                     selectedImage: nil)
        
        let moreNavigation = UINavigationController()
        moreNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        // Setup TabBarViewController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mapNavigation, timelineNavigation, moreNavigation]
        
        // A request is sent to download user posts each time the user clicks the timeline icon
        tabBarController.rx.didSelect
            .compactMap { ($0 as? UINavigationController)?.viewControllers.first }
            .compactMap { $0 as? TimelineViewController }
            .subscribe(onNext: { viewController in
                viewController.viewModel.downloadUserPost.onNext(Void())
            })
            .disposed(by: disposeBag)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        // Setup Coordinators
        let mapCoordinator = MapCoordinator(navigationController: mapNavigation)
        coordinate(to: mapCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        let timelineCoordinator = TimelineCoordinator(navigationController: timelineNavigation)
        coordinate(to: timelineCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        let moreCoordinator = MoreCoordinator(navigationController: moreNavigation)
        coordinate(to: moreCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
        
        return .never()
    }
}
