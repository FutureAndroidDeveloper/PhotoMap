//
//  FirebaseDownloadPostsInRegionTests.swift
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

@testable import PhotoMap

class FirebaseDownloadPostsInRegionTests: XCTestCase {
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
        
        firebaseNotificationDelegate = FirebaseNotificationDelegate()
        firebaseUploadDelegate = FirebaseUploadDelegate()
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
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0, hexColor: "test", category: "test",
                                  postDescription: nil, imageUrl: nil,
                                  userId: "test", coordinate: coordinate)
        
        let expectedResult = [post]
        
        firebaseDownloadDelegate = MockFirebaseDownloadDelegate(mockPost: post)
        coreDataService = MockUniquePostAlwaysTrue()
        
        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
                                 locationService: locationService,
                                 dateService: dateService,
                                 firebaseService: firebaseService,
                                 firebaseNotificationDelegate: firebaseNotificationDelegate,
                                 firebaseUploadDelegate: firebaseUploadDelegate,
                                 firebaseDownloadDelegate: firebaseDownloadDelegate,
                                 firebaseRemoveDelegate: firebaseRemoveDelegate,
                                 coreDataService: coreDataService)
        
        let distance =  CLLocationDistance(exactly: 0)!
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: distance, longitudinalMeters: distance)
        
        viewModel.coordinateInterval.onNext(region)
        
        XCTAssertEqual(try viewModel.posts.take(1).toBlocking().first(), expectedResult)
    }
}


class MockFirebaseDownloadDelegate: FirebaseDownloading {
    private var mockPost: PostAnnotation!
    
    init(mockPost: PostAnnotation) {
        self.mockPost = mockPost
    }
    
    func downloadUserPosts() -> Observable<[PostAnnotation]> {
        return .empty()
    }
    
    func download(in region: MKCoordinateRegion, uncheckedCategories categories: [String]) -> Observable<[PostAnnotation]> {
        return .just([mockPost])
    }
    
    func getCategories() -> Observable<[PhotoCategory]> {
        return .empty()
    }
}

