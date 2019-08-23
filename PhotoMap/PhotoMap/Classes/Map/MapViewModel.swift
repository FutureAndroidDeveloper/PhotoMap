//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/31/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation.CLLocation
import MapKit.MKMapView

class MapViewModel {
    
    private let disposebag = DisposeBag()
    
    // MARK: - Inputs
    
    /// Call to show Photo Sheet or request Photo Permission
    let cameraButtonTapped: AnyObserver<Void>
    
    /// Check location permission
    let locationButtonTapped: AnyObserver<Void>
    
    let photoLibrarySelected: AnyObserver<Void>
    
    let postCreated: AnyObserver<PostAnnotation>
    
    let fullPhotoTapped: AnyObserver<PostAnnotation>
    
    let timestamp: AnyObserver<Int>
    
    let location: AnyObserver<CLLocation>
    
    let coordinateInterval: AnyObserver<MKCoordinateRegion>
    
    
    
    // MARK: - Outputs
    
    /// Emits when we should provide the necessary Permissions
    let showPermissionMessage: Observable<String>
    
    let showPhotoLibrary: Observable<Void>
    
    let showImageSheet: Observable<Void>
    
    let post: Observable<PostAnnotation>
    
    let showFullPhoto: Observable<PostAnnotation>
    
    let shortDate: Observable<String>
    
    let isLoading: Observable<Bool>
    
    let error: Observable<String>
    
    let posts: Observable<[PostAnnotation]>
    
    // MARK: - Initialization
    
    init(photoLibraryService: PhotoLibraryService = PhotoLibraryService(),
         locationService: LocationService = LocationService(),
         dateService: DateService = DateService(),
         firebaseService: FirebaseService = FirebaseService()) {
        
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
        
        let _location = PublishSubject<CLLocation>()
        location = _location.asObserver()
        
        let _post = PublishSubject<PostAnnotation>()
        postCreated = _post.asObserver()
        
        let _isLoading = PublishSubject<Bool>()
        isLoading = _isLoading.asObservable()
        
        let _error = PublishSubject<String>()
        error = _error.asObservable()
        
        let _coordinateInterval = PublishSubject<MKCoordinateRegion>()
        coordinateInterval = _coordinateInterval.asObserver()
        
        let _showFullPhoto = PublishSubject<PostAnnotation>()
        fullPhotoTapped = _showFullPhoto.asObserver()
        showFullPhoto = _showFullPhoto.asObservable()
        
        var set = Set<String>()
        var uniqPosts = [PostAnnotation]()
        
        let _posts = PublishSubject<[PostAnnotation]>()
        posts = _posts.asObservable()

        _ = _coordinateInterval.flatMapLatest { firebaseService.download(region: $0) }
            .map { posts -> [PostAnnotation] in
                var test = [PostAnnotation]()
                for post in posts {
                    if set.contains(post.imageUrl!) {
                        continue
                    } else {
                        set.insert(post.imageUrl!)
                        test.append(post)
                    }
                }
                return test
            }
            .map { uniq in
                uniqPosts.append(contentsOf: uniq)
                return uniqPosts
            }
            .catchErrorJustReturn(uniqPosts)
            .bind(to: _posts)
        
        let _timestamp = PublishSubject<Int>()
        timestamp = _timestamp.asObserver()
        shortDate = _timestamp.asObservable()
            .compactMap { dateService.getShortDate(timestamp: $0) }
        
        _ = _post.asObservable()
            .map { _ in return true }
            .bind(to: _isLoading)
        
        let lastLocation = _location.sample(_post)
        
        post = Observable.zip(_post, lastLocation)
            .flatMap { (post, location) -> Observable<PostAnnotation> in
                post.coordinate = location.coordinate
                return firebaseService.upload(post: post)
                    .andThen(Observable.just(post))
            }
            .do(onNext: { _ in
                _isLoading.onNext(false)
            }, onError: { error in
                _error.onNext(error.localizedDescription)
            })
        
        _locationButtonTapped.asObservable()
            .flatMap { locationService.authorized }
            .filter { $0 == false }
            .map { _ in "Allow access to location." }
            .bind(to: _showPermissionMessage)
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
