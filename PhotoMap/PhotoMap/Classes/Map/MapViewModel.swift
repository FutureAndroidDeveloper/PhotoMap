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
    let locationButtonTapped: AnyObserver<Void>
    let photoLibrarySelected: AnyObserver<Void>
    let postCreated: AnyObserver<PostAnnotation>
    let fullPhotoTapped: AnyObserver<PostAnnotation>
    let timestamp: AnyObserver<Int>
    let location: AnyObserver<CLLocation>
    let coordinateInterval: AnyObserver<MKCoordinateRegion>
    let showCategoriesFilter: AnyObserver<Void>
    let categoriesDidSelected: AnyObserver<Void>
    let removePostTapped: AnyObserver<PostAnnotation>
    let editablePostTapped: AnyObserver<PostAnnotation>
    let createPostAtMapPointTapped: AnyObserver<Void>
    
    // MARK: - Outputs
    let showPermissionMessage: Observable<String>
    let showPhotoLibrary: Observable<Void>
    let showImageSheet: Observable<Void>
    let showFullPhoto: Observable<PostAnnotation>
    let shortDate: Observable<String>
    let isLoading: Observable<Bool>
    let error: Observable<String>
    let posts: Observable<[PostAnnotation]>
    let categoriesTapped: Observable<Void>
    let editablePost: Observable<PostAnnotation>
    
    // MARK: - Initialization
    init(photoLibraryService: Authorizing = PhotoLibraryService(),
         locationService: Authorizing = LocationService(),
         dateService: DateService = DateService(),
         firebaseService: FirebaseDeleagate = FirebaseService(),
         firebaseNotificationDelegate: FirebaseNotification = FirebaseNotificationDelegate(),
         firebaseUploadDelegate: FirebaseUploading = FirebaseUploadDelegate(),
         firebaseDownloadDelegate: FirebaseDownloading = FirebaseDownloadDelegate(),
         firebaseRemoveDelegate: FirebaseRemovable = FirebaseRemoveDelegate(),
         coreDataService: DataBase = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate)) {
        
        firebaseService.setNotificationDelegate(firebaseNotificationDelegate)
        firebaseService.setUploadDelegate(firebaseUploadDelegate)
        firebaseService.setDownloadDelegate(firebaseDownloadDelegate)
        firebaseService.setRemoveDelegate(firebaseRemoveDelegate)
        
        let _locationButtonTapped = PublishSubject<Void>()
        locationButtonTapped = _locationButtonTapped.asObserver()
        
        let _cameraButtopTapped = PublishSubject<Void>()
        cameraButtonTapped = _cameraButtopTapped.asObserver()
        
        let _editablePost = PublishSubject<PostAnnotation>()
        editablePostTapped = _editablePost.asObserver()
        editablePost = _editablePost.asObservable()
        
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
        
        let _removePost = PublishSubject<PostAnnotation>()
        removePostTapped = _removePost.asObserver()

        _ = firebaseService.categoryDidAdded()
            .flatMap { coreDataService.save(category: $0).andThen(Observable.just($0)) }
            .subscribe(onNext: { category in
                print(category.engName)
            })
        
        // I can add removed category to ignore list
        _ = firebaseService.categoryDidRemoved()
            .subscribe(onNext: { category in
                coreDataService.removeCategoryFromCoredata(category)
            })
        
        // Handle Error
        firebaseService.postDidRemoved()
            .do(onNext: { coreDataService.removePostFromCoredata($0) })
            .subscribe(onNext: { _ in
                _categories.onNext(Void())
            })
            .disposed(by: disposebag)
        
        _removePost
            .flatMap { firebaseService.removeIncorrectPost($0) }
            .subscribe(onNext: { (post) in
                //
            })
            .disposed(by: disposebag)
        
        let defaults = UserDefaults.standard
        var visiblePosts = [PostAnnotation]()
        
        // remove old posts then user connects to application
        _ = coreDataService.fetch(without: [])
            .flatMap { firebaseService.removeOldPost(posts: $0) }
            .do(onNext: { post in
                coreDataService.removePostFromCoredata(post)
            })
            .subscribe(onNext: { oldPost in
                if visiblePosts.contains(oldPost) {
                    let index = visiblePosts.firstIndex(of: oldPost)!
                    visiblePosts.remove(at: index)
                }
                _posts.onNext(visiblePosts)
            })
        
        coreDataService.fetch(without: defaults.array(forKey: "savedCategories") as? [String] ?? [])
            .do(onNext: { savedPosts in
                visiblePosts.append(contentsOf: savedPosts)
                _posts.onNext(savedPosts)
            })
            .subscribe()
            .dispose()

        _ = _categories
            .flatMap { _ in
                coreDataService.fetch(without: defaults.array(forKey: "savedCategories") as? [String] ?? [])
            }
            .subscribe(onNext: { filteredPosts in
                visiblePosts.removeAll()
                visiblePosts.append(contentsOf: filteredPosts)
                _posts.onNext(filteredPosts)
            })
        
        _coordinateInterval
            .flatMapLatest { region in
                firebaseService.download(in: region,
                                         uncheckedCategories: defaults.array(forKey: "savedCategories") as? [String] ?? [])
            }
            .compactMap { $0.first }
            .filter { coreDataService.isUnique(postAnnotation: $0) }
            .flatMap { loadedPost -> Observable<PostAnnotation> in
                return coreDataService.save(postAnnotation: loadedPost)
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
            .disposed(by: disposebag)
        
        let _timestamp = PublishSubject<Int>()
        timestamp = _timestamp.asObserver()
        shortDate = _timestamp.asObservable()
            .compactMap { dateService.getShortDate(timestamp: $0, yearLength: .long) }
        
        _post.asObservable()
            .map { _ in return true }
            .bind(to: _isLoading)
            .disposed(by: disposebag)
        
        let lastLocation = _location.sample(_post)
        
        Observable.zip(_post, lastLocation)
            .flatMap { (post, location) -> Observable<PostAnnotation> in
                post.coordinate = location.coordinate
                return firebaseService.upload(post: post)
                    .andThen(coreDataService.save(postAnnotation: post))
                    .andThen(Observable.just(post))
            }
            .subscribe(onNext: { newPost in
                _isLoading.onNext(false)
                if !visiblePosts.contains(newPost) {
                    visiblePosts.append(newPost)
                }
                _posts.onNext(visiblePosts)
            }, onError: { error in
                _error.onNext(error.localizedDescription)
            })
            .disposed(by: disposebag)
        
        _locationButtonTapped.asObservable()
            .flatMap { locationService.authorized }
            .filter { $0 == false }
            .map { _ in R.string.localizable.accessToLocation() }
            .bind(to: _showPermissionMessage)
            .disposed(by: disposebag)
        
        let _createPostAtMapPointTapped = PublishSubject<Void>()
        createPostAtMapPointTapped = _createPostAtMapPointTapped.asObserver()
        
        let isAuthorizedPhotoLibrary = _createPostAtMapPointTapped
            .flatMap { photoLibraryService.authorized }
            .share(replay: 1)
        
        isAuthorizedPhotoLibrary
            .filter { $0 }
            .map { _ in return Void() }
            .bind(to: _showImageSheet)
            .disposed(by: disposebag)
        
        isAuthorizedPhotoLibrary
            .filter { !$0 }
            .map { _ in R.string.localizable.accessToPhotos() }
            .bind(to: _showPermissionMessage)
            .disposed(by: disposebag)
        
        let isAuthorized = _cameraButtopTapped.asObservable()
            .do(onNext: { _ in
                _locationButtonTapped.onNext(Void())
            })
            .flatMap { photoLibraryService.authorized }
            .share(replay: 1)
        
        isAuthorized
            .filter { $0 }
            .map { _ in return Void() }
            .bind(to: _showImageSheet)
            .disposed(by: disposebag)
        
        isAuthorized
            .filter { !$0 }
            .map { _ in R.string.localizable.accessToPhotos() }
            .bind(to: _showPermissionMessage)
            .disposed(by: disposebag)
    }
}
