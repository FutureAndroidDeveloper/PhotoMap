//
//  FirebaseRemoveTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class FirebaseRemoveTests: XCTestCase {
    var firebaseUpload: FirebaseUploading!
    var firebaseRemove: FirebaseRemovable!
    var firebaseDownload: FirebaseDownloadSinglePost!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseUpload = FirebaseUploadDelegate()
        firebaseRemove = FirebaseRemoveDelegate()
        firebaseDownload = FirebaseDownloadSinglePost()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        firebaseUpload = nil
        firebaseRemove = nil
        firebaseDownload = nil
    }

    
    //MARK: - removeIncorrectPost Tests
    func testRemoveIncorrectPostReturnRemovedPost() {
        let image = R.image.authentication.clear()!
        let post = PostAnnotation(image: image, date: 0, hexColor: "test", category: "test", postDescription: "test", userId: "test")
        
        let removedPost = scheduler.createObserver(PostAnnotation.self)
        let expectation = XCTestExpectation(description: "removed post")
        
        firebaseUpload
            .upload(post: post)
            .andThen(Observable<Void>.just(Void()))
            .flatMap { [weak self] _ -> Single<PostAnnotation> in
                guard let self = self else { return .never() }
                return self.firebaseDownload.getPost(userId: "test")
            }
            .flatMap { [weak self] newPost -> Observable<PostAnnotation> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeIncorrectPost(newPost)
            }
            .do(onNext: { removedPost in
                post.imageUrl = removedPost.imageUrl
                expectation.fulfill()
            })
            .bind(to: removedPost)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 50)
        XCTAssertEqual(removedPost.events, [
            .next(0, post),
            .completed(0)
        ])
    }
    
    
    //MARK: - removeCategory Tests
    func testRemoveCategoryReturnRemovedCategory() {
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        let removedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "removed category")
        
        let uploadNewCategorySignal = PublishSubject<Void>()
        uploadNewCategorySignal
            .asObservable()
            .flatMap { [weak self] _ -> Observable<PhotoCategory> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeCategory(category)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: removedCategory)
            .disposed(by: bag)
        
        firebaseUpload
            .addNewCategory(category)
            .subscribe(onCompleted: {
                uploadNewCategorySignal.onNext(Void())
            })
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(removedCategory.events, [
            .next(0, category)
        ])
    }
    
    func testRemoveIncorrectCategoryReturnError() {
        let category = PhotoCategory(hexColor: "unkown", engName: "unkown", ruName: "unkown")
        
        let removedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "removed category")
        let expectedError = FirebaseError.badCategory
        
        firebaseRemove.removeCategory(category)
            .do(onError: { _ in
                expectation.fulfill()
            })
            .bind(to: removedCategory)
            .disposed(by: bag)

        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(removedCategory.events, [
            .error(0, expectedError)
        ])
    }
}
