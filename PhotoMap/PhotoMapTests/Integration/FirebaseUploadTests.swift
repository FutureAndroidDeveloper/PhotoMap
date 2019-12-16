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
    var firebaseRemove: FirebaseRemovable!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseUpload = FirebaseUploadDelegate()
        firebaseRemove = FirebaseRemoveDelegate()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        firebaseUpload = nil
        firebaseRemove = nil
        // I have to manually delete the test ones: category, post, user and photo
    }

    // MARK: - uploadImage Tests
    func testUploadImageReturnImageUrl() {
        let metadata = FirebaseReferences.shared.defaultMetadata
        let image = R.image.authentication.clear()!
        let post = PostAnnotation(image: image, date: 0, hexColor: "test", category: "test", postDescription: "test", userId: "test")
        
        let savedUmageUrl = scheduler.createObserver(String.self)
        let expectedResult = "https://firebasestorage.googleapis.com/"
        let expectation = XCTestExpectation(description: "remove saved image")
        
        firebaseUpload
            .uploadImage(post: post, metadata: metadata)
            .flatMap { [weak self] savedImageUrl -> Observable<String> in
                guard let self = self else { return .empty() }
                post.imageUrl = savedImageUrl.absoluteString
                return self.removeImage(for: post)
            }
            .map { $0.prefix(expectedResult.count) }     // get URL protocol + domain
            .compactMap { String($0) }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: savedUmageUrl)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(savedUmageUrl.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
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
        let post = PostAnnotation(image: image, date: 0, hexColor: "test",
                                  category: "test", postDescription: "test", userId: "test")
        
        let savedPost = scheduler.createObserver(PostAnnotation.self)
        let expectation = XCTestExpectation(description: "remove saved post")
        
        firebaseUpload
            .upload(post: post)
            .andThen(Observable.just(post))
            .flatMap { [weak self] savedPost -> Observable<PostAnnotation> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeIncorrectPost(savedPost)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: savedPost)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(savedPost.events, [
            .next(0, post),
            .completed(0)
        ])
    }
    
    
    // MARK: - addNewCategory Tests
    func testAddNewCategoryIsSuccess() {
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        let savedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "remove saved category")
        
        firebaseUpload
            .addNewCategory(category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] savedCategory -> Observable<PhotoCategory> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeCategory(savedCategory)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: savedCategory)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(savedCategory.events, [
            .next(0, category),
            .completed(0)
        ])
    }
    
    
    // MARK: - save Tests
    func testSaveUserIsSuccess() {
        let user = ApplicationUser(id: "test", email: "test")
        
        let savedUser = scheduler.createObserver(ApplicationUser.self)
        let expectation = XCTestExpectation(description: "remove saved user")
        
        firebaseUpload
            .save(user)
            .andThen(Observable.just(user))
            .flatMap { [weak self] savedUser -> Observable<ApplicationUser> in
                guard let self = self else { return .empty() }
                return self.removeUserFromFirebaseDatabase(savedUser)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: savedUser)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(savedUser.events, [
            .next(0, user),
            .completed(0)
        ])
    }
    
    
    // MARK: - Private Methods
    private func removeUserFromFirebaseDatabase(_ user: ApplicationUser) -> Observable<ApplicationUser> {
        return FirebaseReferences.shared.database.root
            .child("users")
            .child(user.id).rx
            .removeValue()
            .map { _ in user }
            .take(1)
    }
    
    private func removeImage(for post: PostAnnotation) -> Observable<String> {
        let mainString = post.imageUrl!.split(separator: "/").last!
        let startIndex = mainString.index(mainString.startIndex, offsetBy: post.category.count + 3)
        let endIndex = mainString.firstIndex(of: "?")!
        let imageName = String(mainString[startIndex..<endIndex])
            
        return FirebaseReferences.shared.storage
            .child(post.category.lowercased())
            .child(imageName).rx
            .delete()
            .compactMap { post.imageUrl }
            .take(1)
    }
}
