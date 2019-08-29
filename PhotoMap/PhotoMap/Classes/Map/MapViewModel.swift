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
    
    let showCategoriesFilter: AnyObserver<Void>
    
    let categoriesDidSelected: AnyObserver<Void>
    
    
    
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
    
    let categoriesTapped: Observable<Void>
    
    // MARK: - Initialization
    
    init(photoLibraryService: PhotoLibraryService = PhotoLibraryService(),
         locationService: LocationService = LocationService(),
         dateService: DateService = DateService(),
         firebaseService: FirebaseService = FirebaseService(),
         coreDaraService: CoreDataService = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate)) {
        
        let _locationButtonTapped = PublishSubject<Void>()
        locationButtonTapped = _locationButtonTapped.asObserver()
        
        let _cameraButtopTapped = PublishSubject<Void>()
        cameraButtonTapped = _cameraButtopTapped.asObserver()
        
        let _showCategories = PublishSubject<Void>()
        showCategoriesFilter = _showCategories.asObserver()
        categoriesTapped = _showCategories.asObservable()
    
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
        
        let _posts = ReplaySubject<[PostAnnotation]>.create(bufferSize: 1)
        posts = _posts.asObservable()
        
        let _categories = PublishSubject<Void>()
        categoriesDidSelected = _categories.asObserver()
        
        let defaults = UserDefaults.standard
        
        var visiblePosts = [PostAnnotation]()
        
        coreDaraService.fetch(without: defaults.array(forKey: "savedCategories") as? [String] ?? [])
            .do(onNext: { savedPosts in
                visiblePosts.append(contentsOf: savedPosts)
                _posts.onNext(savedPosts)
            })
            .subscribe()
            .dispose()

        _ = _categories
            .flatMap { _ in
                coreDaraService.fetch(without: defaults.array(forKey: "savedCategories") as? [String] ?? [])
            }
            .subscribe(onNext: { filteredPosts in
                visiblePosts.removeAll()
                visiblePosts.append(contentsOf: filteredPosts)
                _posts.onNext(filteredPosts)
            })
        
        _ = _coordinateInterval
            .flatMapLatest { region in
                firebaseService.download(region: region,
                                         uncheckedCategories: defaults.array(forKey: "savedCategories") as? [String] ?? [],
                                         coreDataService: coreDaraService)
            }
            .flatMap { loadedPosts -> Observable<PostAnnotation> in
                guard let loadedPost = loadedPosts.first else { return .empty() }
                return coreDaraService.save(postAnnotation: loadedPost)
                    .andThen(Observable.just(loadedPost))
            }
            .map { loadedPost in
                if !visiblePosts.contains(loadedPost) {
                    visiblePosts.append(loadedPost)
                }
                return visiblePosts
            }
            .catchErrorJustReturn([])
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
                    .andThen(coreDaraService.save(postAnnotation: post))
                    .andThen(Observable.just(post))
            }
            .do(onNext: { newPost in
                _isLoading.onNext(false)
                visiblePosts.append(newPost)
                _posts.onNext(visiblePosts)
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
