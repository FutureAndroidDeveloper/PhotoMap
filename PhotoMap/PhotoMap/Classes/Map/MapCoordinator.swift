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
        let mapViewController = MapViewController.initFromStoryboard(name: "Main")
        navigationController.pushViewController(mapViewController, animated: true)
        
        mapViewController.viewModel = viewModel
        
        viewModel.showPermissionMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.requestPermissions(in: mapViewController, title: title, message: "Please go to Settings and turn on the permissions")
            })
            .disposed(by: disposeBag)
        
        viewModel.showPhotoLibrary
            .flatMap { self.showPhotoLibrary(in: mapViewController) }
            .flatMap { image, date in
                self.showPostViewController(on: mapViewController, image: image, date: date)
            }
            .compactMap { $0 }
            .bind(to: viewModel.postCreated)
            .disposed(by: disposeBag)
        
        viewModel.showFullPhoto
            .subscribe(onNext: { post in
                self.showFullPhotoViewController(post: post)
            })
            .disposed(by: disposeBag)

        return .never()
    }
    
    // MARK: - Private Methods
    
    private func showPhotoLibrary(in viewController: UIViewController) -> Observable<(UIImage, Date)>{
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        viewController.present(imagePicker, animated: true)

        let imagePickerResult = imagePicker.rx.didFinishPickingMediaWithInfo.share()
        
        let image = imagePickerResult.asObservable()
            .map { info -> UIImage in
                return info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
            }
        
        let date = imagePickerResult.asObservable()
            .map { info -> Date in
                let asset = info[UIImagePickerController.InfoKey.phAsset.rawValue] as! PHAsset
                return asset.creationDate!
            }
        
        return Observable.combineLatest(image, date)
            .do(onNext: { _ in
                imagePicker.dismiss(animated: true)
            })
    }

    private func showPostViewController(on rootViewController: UIViewController, image: UIImage, date: Date) -> Observable<PostAnnotation?> {
        let postCoordinator = PostCoordinator(rootViewController: rootViewController, image: image, date: date)
        return coordinate(to: postCoordinator)
            .map { result in
                switch result {
                case .post(let post): return post
                case .cancel: return nil
                }
            }
    }
    
    private func requestPermissions(in viewController: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func showFullPhotoViewController(post: PostAnnotation) -> Observable<Void> {
        let fullPhotoCoordinator = FullPhotoCoordinator(navigationController: navigationController, post: post)
        return coordinate(to: fullPhotoCoordinator)
    }
}
