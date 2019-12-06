//
//  DataBaseTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 11/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import CoreLocation
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class DataBaseTest: XCTestCase {
    var dataBase: CoreDataService!
    var scheduler: TestScheduler!
    var appDelegate: AppDelegate!
    var bag = DisposeBag()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        dataBase = CoreDataService(appDelegate: appDelegate)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataBase = nil
        appDelegate = nil
    }

    func testDeleteionOfIncorrectPost() {
        // 3
        let testPost = PostAnnotation(date: 0, hexColor: "test", category: "test", postDescription: nil, imageUrl: nil, userId: "test", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        XCTAssertNil(dataBase.removePostFromCoredata(testPost))
    }
    
    func testRemovePost() {
        // 4
        let imageURL = "https://interactive-examples.mdn.mozilla.net/media/examples/grapefruit-slice-332-332.jpg"
        let testPost = PostAnnotation(date: 0, hexColor: "test", category: "test", postDescription: "test", imageUrl: imageURL, userId: "test", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        dataBase.save(postAnnotation: testPost)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                XCTAssertEqual(self.dataBase.removePostFromCoredata(testPost), testPost)
            })
            .disposed(by: bag)
    }
    
    
    func testAppDelegateError() {
        // 2 ????
        let imageURL = "https://interactive-examples.mdn.mozilla.net/media/examples/grapefruit-slice-332-332.jpg"
        let testPost = PostAnnotation(date: 0, hexColor: "test", category: "test", postDescription: "test", imageUrl: imageURL, userId: "test", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        dataBase.save(postAnnotation: testPost)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                XCTAssertNil(self.dataBase.removePostFromCoredata(testPost))
            })
            .disposed(by: bag)
    }
    
    
    func testEmptyDataBase() {
        // 3
        let imageURL = "https://interactive-examples.mdn.mozilla.net/media/examples/grapefruit-slice-332-332.jpg"
        let testPost = PostAnnotation(date: 0, hexColor: "test", category: "test", postDescription: "test", imageUrl: imageURL, userId: "test", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
        
        dataBase.save(postAnnotation: testPost)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                XCTAssertNil(self.dataBase.removePostFromCoredata(testPost))
            })
            .disposed(by: bag)
    }
    
    
    func testCorrectFetchCategories() {
        // 4
        let newCategory = PhotoCategory(hexColor: "Test", engName: "Test", ruName: "Test")
        
        dataBase.save(category: newCategory)
            .andThen(dataBase.fetch())
            .subscribe(onNext: { categories in
                print(categories)
                XCTAssertEqual(categories.last!, newCategory)
            })
            .disposed(by: bag)

        dataBase.removeCategoryFromCoredata(newCategory)
    }
    
    
    func testEmptyCategoriesDB() {
        // 3
        var allCategories = [PhotoCategory(hexColor: "Test", engName: "Test", ruName: "Test")]
        allCategories.removeAll()
        
        dataBase.fetch()
            .subscribe(onNext: { categories in
                allCategories = categories
            })
            .disposed(by: bag)
        
        
        // delete all categories
        for category in allCategories {
            dataBase.removeCategoryFromCoredata(category)
        }
        
        // fetch empty DB
        XCTAssertEqual(try dataBase.fetch().toBlocking().first(), [])
        
        // save back removed categories
        for category in allCategories {
            self.dataBase.save(category: category)
                .subscribe()
                .dispose()
        }
    }
    
    
    func testDuplicateCategory() {
        // 2
        var test = PhotoCategory(hexColor: "Test", engName: "Test", ruName: "Test")
        
        dataBase.fetch()
            .subscribe(onNext: { categories in
                guard let lastCategory = categories.last else { return }
                test = lastCategory
            })
            .disposed(by: bag)

        dataBase.save(category: test)
            .subscribe(onCompleted: {}, onError: { error in 
                XCTAssertEqual(error.localizedDescription, CoreDataError.duplicate.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func testCorrectCategorySave() {
        // 3
        var newCategory = PhotoCategory(hexColor: "Test Temp Category",
                                   engName: "Test Temp Category",
                                   ruName: "Test Temp Category")
        
        dataBase.save(category: newCategory)
            .subscribe(onCompleted: {
                XCTAssertEqual(0, 0)
            })
            .disposed(by: bag)
    }
}
