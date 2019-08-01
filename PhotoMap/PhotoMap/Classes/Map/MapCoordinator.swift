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
            .subscribe(onNext: { [weak self] title in
                guard let self = self else { return }
                self.requestPermissions(in: mapViewController, title: title, message: "Please go to Settings and turn on the permissions")
            })
            .disposed(by: disposeBag)
        
        viewModel.showImageSheet
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.displayImageSheet(in: mapViewController)
            })
            .disposed(by: disposeBag)
        
        return .never()
    }
    
    // MARK: - Private Methods
    
    private func showPhotoLibrary(in viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        viewController.present(imagePicker, animated: true)

        imagePicker.rx.didFinishPickingMediaWithInfo
            .map { info -> UIImage in
                if imagePicker.allowsEditing {
                    return info[UIImagePickerController.InfoKey.editedImage.rawValue] as! UIImage
                } else {
                    return info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
                }
            }
            .subscribe(onNext: { image in
                // TODO: - Pass image in View Model if it is necessary
                print("Image in Map Coordinator = \(image)")
                imagePicker.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func displayImageSheet(in viewController: UIViewController) {
        let photoMenu = UIAlertController(title: "Just a text for little test", message: "Choose one because i am Ivan", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default, handler: { _ in
            // TODO: - Camera
        })
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.showPhotoLibrary(in: viewController)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        photoMenu.addAction(cameraAction)
        photoMenu.addAction(libraryAction)
        photoMenu.addAction(cancelAction)
        
        viewController.present(photoMenu, animated: true, completion: nil)
    }
    
    
    private func requestPermissions(in viewController: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
