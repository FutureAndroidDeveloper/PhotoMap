//
//  FullPhotoCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/9/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift

class FullPhotoCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    private let post: PostAnnotation
    
    init(navigationController: UINavigationController, post: PostAnnotation) {
        self.navigationController = navigationController
        self.post = post
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FullPhotoViewModel()
        let fullPhotoViewController = FullPhotoViewController.initFromStoryboard()
        navigationController.pushViewController(fullPhotoViewController, animated: true)
        
        fullPhotoViewController.viewModel = viewModel
        viewModel.postDidLoad.onNext(post)
        
        return viewModel.back.take(1)
    }
}
