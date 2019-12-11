//
//  FirebaseNotificationTests.swift
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

@testable import PhotoMap

class FirebaseUploadTests: XCTestCase {
    var firebaseUpload: FirebaseUploading!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseUpload = FirebaseUploadDelegate()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        firebaseUpload = nil
        // I have to manually delete the test ones: category, post, user and photo
    }

    // MARK: - uploadImage Tests
    func testUploadImageReturnImageUrl() {
        let metadata = FirebaseReferences.shared.defaultMetadata
        let image = R.image.authentication.clear()!
        let post = PostAnnotation(image: image, date: 0, hexColor: "test", category: "test", postDescription: "test", userId: "test")
        
        let expectedResult = "https://firebasestorage.googleapis.com/"

        XCTAssertEqual(try firebaseUpload
            .uploadImage(post: post, metadata: metadata)                // upload image
            .map { $0.absoluteString.prefix(expectedResult.count) }     // get URL protocol + domain
            .compactMap { String($0) }
            .toBlocking()
            .first(), expectedResult)
    }
    
    func testUploadImageWithEmptyPostReturnError() {
        let metadata = FirebaseReferences.shared.defaultMetadata
        let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0, hexColor: "test", category: "test", postDescription: nil, imageUrl: nil, userId: "test", coordinate: location)
        
        let expectedError = FirebaseError.badImage
        let error = scheduler.createObserver(URL.self)
        
        firebaseUpload
            .uploadImage(post: post, metadata: metadata)
            .bind(to: error)
            .disposed(by: bag)
        
        XCTAssertEqual(error.events, [.error(0, expectedError)])
    }
    
    
    // MARK: - upload Tests
    func testUploadPostIsSuccess() {
        let image = R.image.authentication.clear()!
        let post = PostAnnotation(image: image, date: 0, hexColor: "test", category: "test", postDescription: "test", userId: "test")
        
        let result = scheduler.createObserver(Never.self)
        let expectation = XCTestExpectation(description: "complited")
        
        firebaseUpload
            .upload(post: post)
            .asObservable()
            .do(onCompleted: {
                expectation.fulfill()
            })
            .bind(to: result)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(result.events, [.completed(0)])
    }
    
    
    // MARK: - addNewCategory Tests
    func testAddNewCategoryIsSuccess() {
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        let result = scheduler.createObserver(Never.self)
        
        firebaseUpload
            .addNewCategory(category)
            .asObservable()
            .bind(to: result)
            .disposed(by: bag)
        
        XCTAssertEqual(result.events, [.completed(0)])
    }
    
    
    // MARK: - save Tests
    func testSaveUserIsSuccess() {
        let user = ApplicationUser(id: "test", email: "test")
        let result = scheduler.createObserver(Never.self)
        
        firebaseUpload
            .save(user)
            .asObservable()
            .bind(to: result)
            .disposed(by: bag)
        
        XCTAssertEqual(result.events, [.completed(0)])
    }
}
