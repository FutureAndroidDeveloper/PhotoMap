//
//  FirebaseNotificationTests.swift
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

class FirebaseNotificationTests: XCTestCase {
    var firebaseNotification: FirebaseNotification!
    var firebaseUpload: FirebaseUploading!
    var firebaseRemove: FirebaseRemovable!
    var firebaseDownload: FirebaseDownloadSinglePost!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseNotification = FirebaseNotificationDelegate()
        firebaseUpload = FirebaseUploadDelegate()
        firebaseRemove = FirebaseRemoveDelegate()
        firebaseDownload = FirebaseDownloadSinglePost()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        firebaseNotification = nil
        firebaseUpload = nil
        firebaseRemove = nil
        firebaseDownload = nil
    }

    
    //MARK: - postDidRemoved Tests
    func testPostDidRemovedReturnRemovedPost() {
        let image = R.image.authentication.clear()!
        let post = PostAnnotation(image: image, date: 0, hexColor: "test", category: "test", postDescription: "test", userId: "test")
        
        let removedPost = scheduler.createObserver(PostAnnotation.self)
        let expectation = XCTestExpectation(description: "removed post")
        
        firebaseNotification
            .postDidRemoved()
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: removedPost)
            .disposed(by: bag)
        
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
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(removedPost.events, [
            .next(0, post)
        ])
    }
    
    
    //MARK: - categoryDidRemoved Tests
    func testCategoryDidRemovedReturnRemovedCategory() {
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        let removedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "removed category")
        
        firebaseNotification
            .categoryDidRemoved()
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: removedCategory)
            .disposed(by: bag)
        
        firebaseUpload
            .addNewCategory(category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] _ -> Observable<PhotoCategory> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeCategory(category)
            }
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(removedCategory.events, [
            .next(0, category)
        ])
    }
    
    
    //MARK: - categoryDidAdded Tests
    func testCategoryDidAddedReturnAddedCategory() {
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        let removedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "added category")
        
        firebaseNotification
            .categoryDidAdded()
            .take(1)
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: removedCategory)
            .disposed(by: bag)
        
        firebaseUpload
            .addNewCategory(category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] _ -> Observable<PhotoCategory> in
                guard let self = self else { return .empty() }
                return self.firebaseRemove.removeCategory(category)
            }
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(removedCategory.events, [
            .next(0, category),
            .completed(0)
        ])
    }
}
