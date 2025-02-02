//
//  MapCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Photos

class MapCoordinator: BaseCoordinator<Void> {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() -> Observable<Void> {
        let viewModel = MapViewModel()
        let mapViewController = MapViewController.initFromStoryboard()
        navigationController.pushViewController(mapViewController, animated: true)
        
        mapViewController.viewModel = viewModel
        
        viewModel.showPermissionMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.requestPermissions(in: mapViewController, title: title,
                                        message: R.string.localizable.permissionMessage())
            })
            .disposed(by: disposeBag)
        
        viewModel.showPhotoLibrary
            .flatMap { [weak self] _ -> Observable<(UIImage, Date)> in
                guard let self = self else { return .empty() }
                return self.showPhotoLibrary(in: mapViewController)
            }
            .flatMap { [weak self] image, date -> Observable<PostAnnotation?> in
                guard let self = self else { return .empty() }
                return self.showPostViewController(on: mapViewController, image: image, date: date)
            }
            .compactMap { $0 }
            .bind(to: viewModel.postCreated)
            .disposed(by: disposeBag)
        
        viewModel.showFullPhoto
            .flatMap { [weak self] post -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showFullPhotoViewController(post: post)
                    .take(1)
            }
            .subscribe(onNext: {})
            .disposed(by: disposeBag)
        
        viewModel.categoriesTapped
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.showCategoriesViewController(on: mapViewController)
            }
            .bind(to: viewModel.categoriesDidSelected)
            .disposed(by: disposeBag)

        return .never()
    }
    
    // MARK: - Private Methods
    
    private func showPhotoLibrary(in viewController: UIViewController) -> Observable<(UIImage, Date)>{
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        viewController.present(imagePicker, animated: true)

        let imagePickerResult = imagePicker.rx.didFinishPickingMediaWithInfo.share(replay: 1)
        
        let image = imagePickerResult.asObservable()
            .take(1)
            .map { info -> UIImage in
                return info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
            }
        
        let date = imagePickerResult.asObservable()
            .take(1)
            .map { info -> Date in
                let asset = info[UIImagePickerController.InfoKey.phAsset.rawValue] as! PHAsset
                return asset.creationDate!
            }
        
        return Observable.combineLatest(image, date)
            .take(1)
            .do(onNext: { _ in
                imagePicker.dismiss(animated: true)
            })
    }

    private func showPostViewController(on rootViewController: UIViewController,
                                        image: UIImage, date: Date) -> Observable<PostAnnotation?> {
        let postCoordinator = PostCoordinator(rootViewController: rootViewController, image: image, date: date)
        return coordinate(to: postCoordinator)
            .take(1)
            .map { result in
                switch result {
                case .post(let post): return post
                case .cancel: return nil
                }
            }
    }
    
    private func showCategoriesViewController(on rootViewController: UIViewController) -> Observable<Void> {
        let categoriesCoordinator = CategoriesCoordinator(rootViewController: rootViewController)
        return coordinate(to: categoriesCoordinator)
    }
    
    private func requestPermissions(in viewController: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func showFullPhotoViewController(post: PostAnnotation) -> Observable<Void> {
        let fullPhotoCoordinator = FullPhotoCoordinator(navigationController: navigationController, post: post)
        return coordinate(to: fullPhotoCoordinator)
    }
}
