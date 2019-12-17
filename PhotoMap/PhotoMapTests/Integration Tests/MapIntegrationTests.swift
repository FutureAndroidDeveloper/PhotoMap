//
//  MapIntegrationTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

//import XCTest
//import RxCocoa
//import RxSwift
//import RxTest
//import RxBlocking
//
//import CoreLocation.CLLocation
//
//@testable import PhotoMap
//
//class MapIntegrationTests: XCTestCase {
//    var viewModel: MapViewModel!
//    var scheduler: TestScheduler!
//    var coreData: DataBase!
//    var bag: DisposeBag!
//
//    override func setUp() {
////        viewModel = MapViewModel()
//        scheduler = TestScheduler(initialClock: 0)
//        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//        coreData = CoreDataService(appDelegate: appDelegate)
//        bag = DisposeBag()
//    }
//
//    override func tearDown() {
//        viewModel = nil
//    }
//
//    func testCreateNewPostReturnPostsWithNewPost() {
//        let test = "testIntegration"
//        let location = CLLocation(latitude: 0, longitude: 0)
//        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        let post = PostAnnotation(date: 0, hexColor: test, category: test,
//                                  postDescription: nil, imageUrl: test,
//                                  userId: test, coordinate: coordinate)
//
//        let posts = scheduler.createObserver([PostAnnotation].self)
//        let expectedResult = [post]
//        let expectation = XCTestExpectation(description: "")
//        var createdPost = [PostAnnotation]()
//
//        viewModel = MapViewModel(photoLibraryService: PhotoLibraryService(),
//                                 locationService: LocationService(),
//                                 dateService: DateService(),
//                                 firebaseService: FirebaseService(),
//                                 firebaseNotificationDelegate: MockFBNotification(),
//                                 firebaseUploadDelegate: FirebaseUploadDelegate(),
//                                 firebaseDownloadDelegate: MockFBDownload(),
//                                 firebaseRemoveDelegate: MockFBRemove(),
//                                 coreDataService: coreData)
//
//        viewModel.posts
//            .do(onNext: { createdPost.append(contentsOf: $0) })
//            .flatMap { _ in
//                FirebaseRemoveDelegate().removeIncorrectPost(post)
//            }
//            .flatMap { [weak self] removedPost -> Observable<PostAnnotation?> in
//                guard let self = self else { return .empty() }
//                return self.coreData.removePostFromCoredata(removedPost)
//            }
//            .map { _ in createdPost }
//            .do(onNext: { _ in expectation.fulfill() })
//            .bind(to: posts)
//            .disposed(by: bag)
//
//        // send location
//        scheduler.createColdObservable([
//            .next(10, location)
//            ])
//            .bind(to: viewModel.location)
//            .disposed(by: bag)
//
//        // send new post
//        scheduler.createColdObservable([
//            .next(15, post)
//            ])
//            .bind(to: viewModel.postCreated)
//            .disposed(by: bag)
//
//        scheduler.start()
//
//        wait(for: [expectation], timeout: 20)
//        XCTAssertEqual(posts.events, [
//            .next(15, expectedResult)
//        ])
//    }

    
//    func testExampleError() {
//        let location = CLLocation(latitude: 0, longitude: 0)
//        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        let post = PostAnnotation(date: 0, hexColor: "test", category: "test",
//                                  postDescription: nil, imageUrl: nil,
//                                  userId: "test", coordinate: coordinate)
//
//        firebaseNotificationDelegate = MockFirebaseNotificationDelegate(mockPost: post)
//        firebaseUploadDelegate = MockErrorFirebaseUploadingDelegate()
//        coreDataService = MockCoreData()
//
//        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
//                                 locationService: locationService,
//                                 dateService: dateService,
//                                 firebaseService: firebaseService,
//                                 firebaseNotificationDelegate: firebaseNotificationDelegate,
//                                 firebaseUploadDelegate: firebaseUploadDelegate,
//                                 firebaseDownloadDelegate: firebaseDownloadDelegate,
//                                 firebaseRemoveDelegate: firebaseRemoveDelegate,
//                                 coreDataService: coreDataService)
//
//        let errorMessage = scheduler.createObserver(String.self)
//        let expectedErrorMessage = FirebaseError.serializationError.errorDescription!
//
//        viewModel.error
//            .bind(to: errorMessage)
//            .disposed(by: bag)
//
//        // send location
//        scheduler.createColdObservable([
//            .next(10, location)
//            ])
//            .bind(to: viewModel.location)
//            .disposed(by: bag)
//
//        // send new post
//        scheduler.createColdObservable([
//            .next(15, post)
//            ])
//            .bind(to: viewModel.postCreated)
//            .disposed(by: bag)
//
//        scheduler.start()
//
//        XCTAssertEqual(errorMessage.events, [
//            .next(15, expectedErrorMessage)
//            ])
//    }
//}
