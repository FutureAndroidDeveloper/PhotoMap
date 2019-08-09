//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/31/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class MapViewModel {
    
    private let disposebag = DisposeBag()
    
    // MARK: - Inputs
    
    /// Call to show Photo Sheet or request Photo Permission
    let cameraButtonTapped: AnyObserver<Void>
    
    /// Check location permission
    let locationButtonTapped: AnyObserver<Void>
    
    let photoLibrarySelected: AnyObserver<Void>
    
    let postCreated: AnyObserver<PostAnnotation>
    
    // MARK: - Outputs
    
    /// Emits when we should show Photo Sheet
//    let showImageSheet: Observable<Void>
    
    /// Emits when we should provide the necessary Permissions
    let showPermissionMessage: Observable<String>
    
    let showPhotoLibrary: Observable<Void>
    
    let showImageSheet: Observable<Void>
    
    let post: Observable<PostAnnotation>
    
    // MARK: - Initialization
    
    init(photoLibraryService: PhotoLibraryService = PhotoLibraryService(), locationService: LocationService = LocationService()) {
        let _locationButtonTapped = PublishSubject<Void>()
        locationButtonTapped = _locationButtonTapped.asObserver()
        
        let _cameraButtopTapped = PublishSubject<Void>()
        cameraButtonTapped = _cameraButtopTapped.asObserver()
    
        let _showPermissionMessage = PublishSubject<String>()
        showPermissionMessage = _showPermissionMessage.asObservable()
        
        let _showImageSheet = PublishSubject<Void>()
        showImageSheet = _showImageSheet.asObservable()
        
        let _showPhotoLibrary = PublishSubject<Void>()
        photoLibrarySelected = _showPhotoLibrary.asObserver()
        showPhotoLibrary = _showPhotoLibrary.asObservable()
        
        let _post = PublishSubject<PostAnnotation>()
        postCreated = _post.asObserver()
        post = _post.asObservable()

        _locationButtonTapped.asObservable()
            .subscribe(onNext: { _ in
                let locationAuthorized = locationService.authorized
                    .share()

                locationAuthorized
                    .takeLast(1)
                    .filter { $0 == false }
                    .subscribe(onNext: { (_) in
                        _showPermissionMessage.onNext("Allow access to location.")
                    })
                    .disposed(by: self.disposebag)
            })
            .disposed(by: disposebag)
        
        
        _cameraButtopTapped.asObservable()
            .subscribe(onNext: { _ in
                let authorized = photoLibraryService.authorized
                    .share()
                
                authorized
                    .skipWhile { $0 == false }
                    .take(1)
                    .subscribe(onNext: { _ in
                        _showImageSheet.onNext(Void())
                    })
                    .disposed(by: self.disposebag)

                authorized
                    .skip(1)
                    .takeLast(1)
                    .filter { $0 == false }
                    .subscribe(onNext: { (_) in
                        _showPermissionMessage.onNext("Allow access to photos.")
                    })
                    .disposed(by: self.disposebag)
            })
            .disposed(by: disposebag)
    }
}
