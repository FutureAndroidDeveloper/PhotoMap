//
//  PostCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift

/// Type that defines possible coordination results of the `PostCoordinator`.
///
/// - post: Post was created.
/// - cancel: Cancel button was tapped.
enum PostCoordinatorResult {
    case post(PostAnnotation)
    case cancel
}

class PostCoordinator: BaseCoordinator<PostCoordinatorResult> {
    private let rootViewController: UIViewController
    private let postImage: UIImage
    private let creationDate: Date
    
    init(rootViewController: UIViewController, image: UIImage, date: Date) {
        self.rootViewController = rootViewController
        postImage = image
        creationDate = date
    }
    
    override func start() -> Observable<CoordinatorResult> {
        let postViewController = PostViewController.initFromStoryboard(name: "Main")
        let viewModel = PostViewModel()
        postViewController.viewModel = viewModel
        
        viewModel.didSelectedImage.onNext(postImage)
        viewModel.creationDate.onNext(creationDate)
        
        rootViewController.addChild(postViewController)
        postViewController.view.frame = rootViewController.view.frame
        rootViewController.view.addSubview(postViewController.view)
        postViewController.didMove(toParent: rootViewController)
        
        let cancel = viewModel.didCancel.map { _ in CoordinatorResult.cancel }
        let post = viewModel.post.map { CoordinatorResult.post($0) }
        let result = Observable.merge(cancel, post).take(1)
        
        result
            .map { _ in Void() }
            .bind(to: viewModel.dismiss)
            .disposed(by: disposeBag)
        
        return result
            .do(onCompleted: {
                postViewController.removeFromParent()
            })
    }
}
