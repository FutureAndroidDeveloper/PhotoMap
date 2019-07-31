//
//  TabBarCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class TabBarCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        // Setup NavigationControlles
        let mapNavigation = UINavigationController()
        mapNavigation.isNavigationBarHidden = true
        mapNavigation.tabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "compass"), selectedImage: nil)
        
        let timelineNavigation = UINavigationController()
        timelineNavigation.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(named: "timeline"), selectedImage: nil)
        
        let moreNavigation = UINavigationController()
        moreNavigation.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        // Setup TabBarViewController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mapNavigation, timelineNavigation, moreNavigation]
        
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
