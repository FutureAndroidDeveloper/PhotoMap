//
//  CategoriesViewModelTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class CategoriesViewModelTests: XCTestCase {
    var viewModel: CategoriesViewModel!
    
    var firebaseService: FirebaseDeleagate!
    var firebaseNotification: FirebaseNotification!
    var firebaseRemove: FirebaseRemovable!
    var coreDataService: DataBase!
    
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseService = FirebaseService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        firebaseService = nil
        firebaseNotification = nil
        firebaseRemove = nil
        coreDataService = nil
    }

    
    // MARK: - search Tests
    func testSearchReturnFilteredCategories() {
        let categories = createCategories(count: 4)
        firebaseNotification = FBCategoryDidAddedMockArray(categories: categories)
        firebaseRemove = MockFBRemove()
        coreDataService = MockCoreData()
        
        viewModel = CategoriesViewModel(firebaseService: firebaseService,
                                        firebaseNotificationDelegate: firebaseNotification,
                                        firebaseRemoveDelegate: firebaseRemove,
                                        coreDataService: coreDataService)
        
        let filteredCategories = scheduler.createObserver([PhotoCategory].self)
        let search = "test2"
        let expectedCategory = PhotoCategory(hexColor: search,
                                             engName: search,
                                             ruName: search)
        
        viewModel.filteredCategories
            .bind(to: filteredCategories)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, search)
            ])
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(filteredCategories.events, [
            .next(0, [expectedCategory])
        ])
    }
    
    func testEmptySearchReturnAllCategories() {
        let categories = createCategories(count: 4)
        firebaseNotification = FBCategoryDidAddedMockArray(categories: categories)
        firebaseRemove = MockFBRemove()
        coreDataService = MockCoreData()

        viewModel = CategoriesViewModel(firebaseService: firebaseService,
                                        firebaseNotificationDelegate: firebaseNotification,
                                        firebaseRemoveDelegate: firebaseRemove,
                                        coreDataService: coreDataService)

        let filteredCategories = scheduler.createObserver([PhotoCategory].self)
        let search = ""

        viewModel.filteredCategories
            .bind(to: filteredCategories)
            .disposed(by: bag)

        scheduler.createColdObservable([
            .next(0, search)
            ])
            .bind(to: viewModel.searchText)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(filteredCategories.events, [
            .next(0, categories)
        ])
    }
    
    
    // MARK: - categoryDidRemoved Test
    func testRemovedCategoryRemoveFromAllCategories() {
        let categoriesCount = 4
        let categories = createCategories(count: categoriesCount)
        let removaedCategory = categories.last!
        
        firebaseNotification = FBCategoryDidRemovedMockCategory(categories: categories,
                                                                removedCategory: removaedCategory)
        firebaseRemove = MockFBRemove()
        coreDataService = MockRemoveCategoryFromCoredata()
        viewModel = CategoriesViewModel(firebaseService: firebaseService,
                                        firebaseNotificationDelegate: firebaseNotification,
                                        firebaseRemoveDelegate: firebaseRemove,
                                        coreDataService: coreDataService)
        
        let resultCategories = scheduler.createObserver([PhotoCategory].self)
        let expectation = XCTestExpectation(description: "removed post")
        let expectedResult = Array(categories.dropLast())
        
        let fetchedCategories = viewModel.categories
            .share(replay: 1, scope: .whileConnected)
        
        fetchedCategories
            .take(1)
            .map { _ in return Void() }
            .bind(to: (firebaseNotification as! FBCategoryDidRemovedMockCategory)
                .emmitRemovedCategorySignal)
            .disposed(by: bag)
        
        fetchedCategories
            .takeLast(1)
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .bind(to: resultCategories)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(resultCategories.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
    }
    
    // MARK: - removeCategory Test
    func testRemovedCategoryDidTappedRemoveCategooryFromFB() {
        let categoriesCount = 4
        let categories = createCategories(count: categoriesCount)
        let removaedCategory = categories.last!
        
        firebaseNotification = FBCategoryDidRemovedMockCategory(categories: categories,
                                                                removedCategory: removaedCategory)
        firebaseRemove = FBRemoveCategoryMockCategory()
        coreDataService = MockRemoveCategoryFromCoredata()
        viewModel = CategoriesViewModel(firebaseService: firebaseService,
                                        firebaseNotificationDelegate: firebaseNotification,
                                        firebaseRemoveDelegate: firebaseRemove,
                                        coreDataService: coreDataService)
        
        let resultCategories = scheduler.createObserver([PhotoCategory].self)
        let expectation = XCTestExpectation(description: "removed post")
        let expectedResult = Array(categories.dropLast())
        
        let fetchedCategories = viewModel.categories
            .share(replay: 1, scope: .whileConnected)
        
        fetchedCategories
            .take(1)
            .map { _ in return Void() }
            .bind(to: (firebaseNotification as! FBCategoryDidRemovedMockCategory)
                .emmitRemovedCategorySignal)
            .disposed(by: bag)
        
        fetchedCategories
            .takeLast(1)
            .do(onNext: { _ in
                expectation.fulfill()
            })
            .bind(to: resultCategories)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, removaedCategory.engName)
            ])
            .bind(to: viewModel.removeCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(resultCategories.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
    }
    
    
    // MARK: - Private Methods
    private func createCategories(count: Int) -> [PhotoCategory] {
        var result: [PhotoCategory] = []
        
        (0..<count).forEach { index in
            let text = "test\(index)"
            let category = PhotoCategory(hexColor: text,
                                         engName: text,
                                         ruName: text)
            result.append(category)
        }
        return result
    }
}
