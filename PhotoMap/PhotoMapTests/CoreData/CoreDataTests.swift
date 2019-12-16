//
//  CoreDataTests.swift
//  PhotoMapTests
//
//  Created by Кирилл Клименков on 12/15/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

import CoreLocation.CLLocation

@testable import PhotoMap

class CoreDataTests: XCTestCase {
    var dataBase: DataBase!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    var appDelegate: AppDelegate!

    override func setUp() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        dataBase = CoreDataService(appDelegate: appDelegate)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        dataBase = nil
    }
    
//    func testFetch() {
//        dataBase.fetch(without: [])
//            .subscribe(onNext: { posts in
//                posts.forEach { print($0.category) }
//                print()
//                print()
//                print(posts)
//                
//            })
//            .disposed(by: bag)
//    }

    
    // MARK: - save(postAnnotation:) Tests
    func testSaveUniquePostIsCorrect() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0,
                                  hexColor: "testColor",
                                  category: "testCategory",
                                  postDescription: "testDescription",
                                  imageUrl: "testUrl",
                                  userId: "testUserId",
                                  coordinate: coordinate)
        
        
        let savedPost = scheduler.createObserver(PostAnnotation.self)
        let expectation = XCTestExpectation(description: "remove saved post")
        
        // save post to Core Data
        dataBase.save(postAnnotation: post)
            .andThen(Observable.just(post))
            .flatMap { [weak self] post -> Observable<PostAnnotation?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removePostFromCoredata(post)
            }
            .compactMap { $0 }
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .bind(to: savedPost)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(savedPost.events, [
            .next(0, post),
            .completed(0)
        ])
    }
    
    func testSaveDuplicatePost() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0,
                                  hexColor: "testColor",
                                  category: "testCategory",
                                  postDescription: "testDescription",
                                  imageUrl: "testUrl",
                                  userId: "testUserId",
                                  coordinate: coordinate)
        
        let savedPost = scheduler.createObserver(Never.self)
        let removeSignal = ReplaySubject<Void>.create(bufferSize: 1)
        let expectation = XCTestExpectation(description: "remove saved post")
        
        // save post to Core Data
        dataBase.save(postAnnotation: post)
            .andThen(Observable.just(post))
            .flatMap { [weak self] post -> Completable in
                guard let self = self else { return .empty() }
                return self.dataBase.save(postAnnotation: post)
            }
            .asCompletable()
            .do(onCompleted: {
                print("onCompleted")
                removeSignal.onNext(Void())
            })
            .asObservable()
            .bind(to: savedPost)
            .disposed(by: bag)
        
        removeSignal.asObservable()
            .flatMap { [weak self] _ -> Observable<PostAnnotation?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removePostFromCoredata(post)
            }
            .compactMap { $0 }
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(savedPost.events, [
            .completed(0)
        ])
    }
    
    
    // MARK: - save(category:) Tests
    func testSaveUniqueCategoryIsCorrect() {
        let category = PhotoCategory(hexColor: "test",
                                     engName: "test",
                                     ruName: "test")
        
        let savedCategory = scheduler.createObserver(PhotoCategory.self)
        let expectation = XCTestExpectation(description: "remove saved category")
        
        // save category to Core Data
        dataBase.save(category: category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] savedCategory -> Observable<PhotoCategory?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removeCategoryFromCoredata(savedCategory)
            }
            .compactMap { $0 }
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .bind(to: savedCategory)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(savedCategory.events, [
            .next(0, category),
            .completed(0)
            ])
    }
    
    func testSaveDuplicateCategory() {
        let category = PhotoCategory(hexColor: "test",
                                     engName: "test",
                                     ruName: "test")
        
        let savedCategory = scheduler.createObserver(Never.self)
        let removeSignal = ReplaySubject<Void>.create(bufferSize: 1)
        let expectation = XCTestExpectation(description: "remove saved category")
        
        // save post to Core Data
        dataBase.save(category: category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] savedCategory -> Completable in
                guard let self = self else { return .empty() }
                return self.dataBase.save(category: savedCategory)
            }
            .asCompletable()
            .do(onCompleted: {
                removeSignal.onNext(Void())
            })
            .asObservable()
            .bind(to: savedCategory)
            .disposed(by: bag)
        
        removeSignal.asObservable()
            .flatMap { [weak self] _ -> Observable<PhotoCategory?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removeCategoryFromCoredata(category)
            }
            .compactMap { $0 }
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(savedCategory.events, [
            .completed(0)
            ])
    }
    
    
    // MARK: - fetch posts Tests
    func testFetchAllPostsReturnArrayOfPosts() {
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0,
                                  hexColor: "testColor",
                                  category: "testCategory",
                                  postDescription: "testDescription",
                                  imageUrl: "testUrl",
                                  userId: "testUserId",
                                  coordinate: coordinate)
        
        let expectation = XCTestExpectation(description: "")
        var expectedPosts = [PostAnnotation]()
        
        dataBase.save(postAnnotation: post)
            .andThen(Observable.just(post))
            .flatMap { [weak self] _ -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.dataBase.fetch(without: [])
            }
            .do(onNext: { expectedPosts.append(contentsOf: $0) })
            .flatMap { [weak self] _ -> Observable<PostAnnotation?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removePostFromCoredata(post)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(expectedPosts.count > 0)
    }
    
    func testFetchPostsWithIgnoredCategoriesReturnArrayOfPostsWithoutPostsOfTheseCategories() {
        let ignoredCategory = "testCategory".uppercased()
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let post = PostAnnotation(date: 0,
                                  hexColor: "testColor",
                                  category: ignoredCategory,
                                  postDescription: "testDescription",
                                  imageUrl: "testUrl",
                                  userId: "testUserId",
                                  coordinate: coordinate)
        
        let expectation = XCTestExpectation(description: "")
        var expectedPosts = [PostAnnotation]()
        
        dataBase.save(postAnnotation: post)
            .andThen(Observable.just(post))
            .flatMap { [weak self] savedPost -> Observable<[PostAnnotation]> in
                guard let self = self else { return .empty() }
                return self.dataBase.fetch(without: [ignoredCategory])
            }
            .do(onNext: { expectedPosts.append(contentsOf: $0) })
            .flatMap { [weak self] _ -> Observable<PostAnnotation?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removePostFromCoredata(post)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue(!expectedPosts.contains(post))
    }
    
    // MARK: - fetch categories Tests
    func testFetchAllCategoriesReturnArrayOfCategories() {
        let category = PhotoCategory(hexColor: "test",
                                     engName: "test",
                                     ruName: "test")
        
        var expectedCategories = [PhotoCategory]()
        let expectation = XCTestExpectation(description: "remove saved category")
        
        dataBase.save(category: category)
            .andThen(Observable.just(category))
            .flatMap { [weak self] _ -> Observable<[PhotoCategory]> in
                guard let self = self else { return .empty() }
                return self.dataBase.fetch()
            }
            .do(onNext: { expectedCategories.append(contentsOf: $0) })
            .flatMap { [weak self] _ -> Observable<PhotoCategory?> in
                guard let self = self else { return .empty() }
                return self.dataBase.removeCategoryFromCoredata(category)
            }
            .do(onNext: { _ in expectation.fulfill() })
            .subscribe()
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertTrue((expectedCategories.count > 0)
            && (expectedCategories.contains(category)))
    }
}
