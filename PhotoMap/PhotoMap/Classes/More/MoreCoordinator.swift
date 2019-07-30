//
//  MoreCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class MoreCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let moreViewController = MoreViewController.initFromStoryboard(name: "Main")
        navigationController.pushViewController(moreViewController, animated: true)
        
        return .never()
    }
}
