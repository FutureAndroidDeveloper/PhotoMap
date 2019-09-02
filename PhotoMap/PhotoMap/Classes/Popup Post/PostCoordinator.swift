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
        
        let navigationController = UINavigationController(rootViewController: postViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.tintColor = .white
        navigationController.modalPresentationStyle = .overCurrentContext
        rootViewController.present(navigationController, animated: false, completion: nil)
        
        viewModel.showFullPhoto
            .flatMap { [weak self] post -> Observable<Void> in
                guard let self = self else { return .empty() }
                self.rootViewController.tabBarController?.tabBar.isHidden = true
                return self.showFullPhotoViewController(post: post, navigationController: navigationController)
                    .take(1)
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.rootViewController.tabBarController?.tabBar.isHidden = false
            })
            .disposed(by: disposeBag)
        
        let cancel = viewModel.didCancel.take(1).map { _ in CoordinatorResult.cancel }
        let post = viewModel.post.take(1).map { CoordinatorResult.post($0) }
        let result = Observable.merge(cancel, post).share(replay: 1)
        
        return result
            .flatMap { _ in
                postViewController.moveOut()
            }
            .flatMap { _ -> Observable<CoordinatorResult> in
                return result
            }
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.rootViewController.dismiss(animated: false, completion: nil)
            })
    }
    
    private func showFullPhotoViewController(post: PostAnnotation, navigationController: UINavigationController) -> Observable<Void> {
        let fullPhotoCoordinator = FullPhotoCoordinator(navigationController: navigationController, post: post)
        return coordinate(to: fullPhotoCoordinator)
    }
}
