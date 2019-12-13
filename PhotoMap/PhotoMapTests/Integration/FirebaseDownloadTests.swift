//
//  FirebaseDownloadTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/11/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

import CoreLocation.CLLocation
import MapKit.MKGeometry
import Firebase
import FirebaseAuth

@testable import PhotoMap

struct FirebaseConfigurator {
    static let shared = FirebaseConfigurator()
    private init() {
        FirebaseApp.configure()
    }
}

class FirebaseDownloadTests: XCTestCase {
    var firebaseDownload: FirebaseDownloading!
    var firebaseAuth: FirebaseAuthentication!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
        
    override func setUp() {
        firebaseDownload = FirebaseDownloadDelegate()
        firebaseAuth = FirebaseAuthDelegate()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
        _ = FirebaseConfigurator.shared
    }

    override func tearDown() {
        firebaseDownload = nil
        firebaseAuth = nil
    }


    // MARK: - downloadUserPosts Tests
    func testDownloadUserPostsReturnArrayOfUserPosts() {
        let email = "kirill@mail.com"
        let password = "1029384756gexa"
        
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let imageUrl = "https://firebasestorage.googleapis.com/v0/b/photomap-3ddfd.appspot.com/o/shared%2F723EC4FA-7684-44BE-AA81-E76C6110B07B.jpg?alt=media&token=9785d7de-3985-4913-9547-42a1a862652b"
        let post = PostAnnotation(date: 0, hexColor: "", category: "", postDescription: nil, imageUrl: imageUrl, userId: "", coordinate: location)
        
        let posts = scheduler.createObserver([PostAnnotation].self)
        let expectation = XCTestExpectation(description: "loaded posts")
        let expectedResult = [post]
        
        firebaseAuth
            .signIn(withEmail: email, password: password)
            .flatMap { [weak self] _ -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.firebaseDownload.downloadUserPosts()
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: posts)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(posts.events, [
            .next(0, expectedResult),
            .completed(0)
            ])
    }
    
    
    // MARK: - download Tests
    func testDownloadInCorrectRegionReturnArrayOfPosts() {
        let email = "kirill@mail.com"
        let password = "1029384756gexa"
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = CLLocationCoordinate2D(latitude: 40.76631640967028,
                                            longitude: -73.92686511332171)
        let region = MKCoordinateRegion(center: center, span: span)
        
        let imageUrl = "https://firebasestorage.googleapis.com/v0/b/photomap-3ddfd.appspot.com/o/shared%2F723EC4FA-7684-44BE-AA81-E76C6110B07B.jpg?alt=media&token=9785d7de-3985-4913-9547-42a1a862652b"
        let post = PostAnnotation(date: 0, hexColor: "", category: "", postDescription: nil, imageUrl: imageUrl, userId: "", coordinate: center)
        
        let posts = scheduler.createObserver([PostAnnotation].self)
        let expectation = XCTestExpectation(description: "loaded posts")
        let expectedResult = [post]
        
        firebaseAuth
            .signIn(withEmail: email, password: password)
            .flatMap { [weak self] _ -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.firebaseDownload.download(in: region, uncheckedCategories: [])
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: posts)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(posts.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
    }
    
    func testDownloadInRegionWithOutPostsReturnEmptyArray() {
        let email = "kirill@mail.com"
        let password = "1029384756gexa"
        
        let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
        let center = CLLocationCoordinate2D(latitude: 40.76631640967028,
                                            longitude: -73.92686511332171)
        let region = MKCoordinateRegion(center: center, span: span)
        
        let posts = scheduler.createObserver([PostAnnotation].self)
        let expectation = XCTestExpectation(description: "loaded posts")
        let expectedResult = [PostAnnotation]()
        
        firebaseAuth
            .signIn(withEmail: email, password: password)
            .flatMap { [weak self] _ -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.firebaseDownload.download(in: region, uncheckedCategories: [])
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: posts)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(posts.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
    }
    
    func testDownloadWithIgnoredCategoryReturnArrayWithoutPostsOfTheseCategories() {
        let email = "kirill@mail.com"
        let password = "1029384756gexa"
        let category = "shared"
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = CLLocationCoordinate2D(latitude: 40.76631640967028,
                                            longitude: -73.92686511332171)
        let region = MKCoordinateRegion(center: center, span: span)
        
        let posts = scheduler.createObserver([PostAnnotation].self)
        let expectation = XCTestExpectation(description: "loaded posts")
        let expectedResult = [PostAnnotation]()
        
        firebaseAuth
            .signIn(withEmail: email, password: password)
            .flatMap { [weak self] _ -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.firebaseDownload.download(in: region,
                                                      uncheckedCategories: [category])
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: posts)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(posts.events, [
            .next(0, expectedResult),
            .completed(0)
            ])
    }
    
    
    //MARK: - getCategories Tests
    func testGetCategoriesReturnArrayOfCategories() {
        let categories = scheduler.createObserver([PhotoCategory].self)
        let expectation = XCTestExpectation(description: "categories")
        
        firebaseDownload.getCategories()
            .do(onNext: { (categories) in
                categories.forEach { print($0) }
                expectation.fulfill()
            })
            .bind(to: categories)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(categories.events.first!.value.element?.isEmpty, false)
    }
}
