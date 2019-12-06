//
//  UploadNewPostFirebaseTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking
import MapKit
import FirebaseStorage.FIRStorageMetadata

@testable import PhotoMap

class UploadNewPostFirebaseTests: XCTestCase {
    var photoLibraryService: Authorizing!
    var locationService: Authorizing!
    var dateService: DateService!
    
    var firebaseService: FirebaseDeleagate!
    var firebaseNotificationDelegate: FirebaseNotification!
    var firebaseUploadDelegate: FirebaseUploading!
    var firebaseDownloadDelegate: FirebaseDownloading!
    var firebaseRemoveDelegate: FirebaseRemovable!
    var coreDataService: DataBase!
    
    var viewModel: MapViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    override func setUp() {
        photoLibraryService = PhotoLibraryService()
        locationService = LocationService()
        dateService = DateService()
        
//        firebaseNotificationDelegate = FirebaseNotificationDelegate()
        firebaseDownloadDelegate = FirebaseDownloadDelegate()
        firebaseRemoveDelegate = FirebaseRemoveDelegate()
        
        firebaseService = FirebaseService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        photoLibraryService = nil
        locationService = nil
        dateService = nil
        coreDataService = nil
        
        firebaseNotificationDelegate = nil
        firebaseUploadDelegate = nil
        firebaseDownloadDelegate = nil
        firebaseRemoveDelegate = nil
        
        firebaseService = nil
        scheduler = nil
    }

    func testExample() {
        let location = CLLocation(latitude: 0, longitude: 0)
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0, hexColor: "test", category: "test",
                                  postDescription: nil, imageUrl: nil,
                                  userId: "test", coordinate: coordinate)
        
        firebaseNotificationDelegate = MockFirebaseNotificationDelegate(mockPost: post)
        firebaseUploadDelegate = MockFirebaseUploadingDelegate()
        coreDataService = MockCoreData()
        
        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
                                 locationService: locationService,
                                 dateService: dateService,
                                 firebaseService: firebaseService,
                                 firebaseNotificationDelegate: firebaseNotificationDelegate,
                                 firebaseUploadDelegate: firebaseUploadDelegate,
                                 firebaseDownloadDelegate: firebaseDownloadDelegate,
                                 firebaseRemoveDelegate: firebaseRemoveDelegate,
                                 coreDataService: coreDataService)

        let posts = scheduler.createObserver([PostAnnotation].self)
        let expectedResult = [post]
        
        viewModel.posts
            .bind(to: posts)
            .disposed(by: bag)
        
        // send location
        scheduler.createColdObservable([
            .next(10, location)
            ])
            .bind(to: viewModel.location)
            .disposed(by: bag)
        
        // send new post
        scheduler.createColdObservable([
            .next(15, post)
            ])
            .bind(to: viewModel.postCreated)
            .disposed(by: bag)

        scheduler.start()
        
        XCTAssertEqual(posts.events, [
            .next(15, expectedResult)
            ])
    }
    
    
    func testExampleError() {
        let location = CLLocation(latitude: 0, longitude: 0)
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0, hexColor: "test", category: "test",
                                  postDescription: nil, imageUrl: nil,
                                  userId: "test", coordinate: coordinate)
        
        firebaseNotificationDelegate = MockFirebaseNotificationDelegate(mockPost: post)
        firebaseUploadDelegate = MockErrorFirebaseUploadingDelegate()
        coreDataService = MockCoreData()
        
        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
                                 locationService: locationService,
                                 dateService: dateService,
                                 firebaseService: firebaseService,
                                 firebaseNotificationDelegate: firebaseNotificationDelegate,
                                 firebaseUploadDelegate: firebaseUploadDelegate,
                                 firebaseDownloadDelegate: firebaseDownloadDelegate,
                                 firebaseRemoveDelegate: firebaseRemoveDelegate,
                                 coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = FirebaseError.serializationError.errorDescription!
        
        viewModel.error
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        // send location
        scheduler.createColdObservable([
            .next(10, location)
            ])
            .bind(to: viewModel.location)
            .disposed(by: bag)
        
        // send new post
        scheduler.createColdObservable([
            .next(15, post)
            ])
            .bind(to: viewModel.postCreated)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(15, expectedErrorMessage)
            ])
    }
}


class MockFirebaseUploadingDelegate: FirebaseUploading {
    func upload(post: PostAnnotation) -> Completable {
        return .empty()
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata = FirebaseReferences.shared.defaultMetadata) -> Observable<URL> {
        return .empty()
    }
    
    func addNewCategory(_ category: PhotoCategory) -> Completable {
        return .empty()
    }
    
    func save(_ user: ApplicationUser) -> Completable {
        return .empty()
    }
}

class MockFirebaseNotificationDelegate: FirebaseNotification {
    private var mockPost: PostAnnotation!
    
    init(mockPost: PostAnnotation) {
        self.mockPost = mockPost
    }
    
    func postDidRemoved() -> Observable<PostAnnotation> {
        return .just(mockPost)
    }
    
    func categoryDidRemoved() -> Observable<PhotoCategory> {
        return .empty()
    }
    
    func categoryDidAdded() -> Observable<PhotoCategory> {
        return .empty()
    }
}


class MockErrorFirebaseUploadingDelegate: FirebaseUploading {
    func upload(post: PostAnnotation) -> Completable {
        return .error(FirebaseError.serializationError)
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata = FirebaseReferences.shared.defaultMetadata) -> Observable<URL> {
        return .empty()
    }
    
    func addNewCategory(_ category: PhotoCategory) -> Completable {
        return .empty()
    }
    
    func save(_ user: ApplicationUser) -> Completable {
        return .empty()
    }
}
