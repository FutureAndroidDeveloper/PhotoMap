//
//  TimelineTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 11/27/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class TimelineTest: XCTestCase {
    var viewModel: TimelineViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    // MARK: - MOCK
    // firebaseService.downloadUserPosts()
    // firebaseDownloadDelegate: FirebaseDownloading
    
    // coreDataService.fetch()
    
    
    override func setUp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let firebaseService = FirebaseService()
        let dateService = DateService()
        let coreDataService = CoreDataService(appDelegate: appDelegate)
        
        viewModel = TimelineViewModel(firebaseService: firebaseService,
                                      dateService: dateService,
                                      coreDataService: coreDataService)
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
    }

    
    // 1. remove implementation of getLocalizedCategoryName
    // 2. start this test and take screenshot that this test is failed
    // 3. write bad implementation
    // 4. run this test and take screenshot that this test is successed
    // 5. paste first implementation of function back (like refactoring)
    func testGetLocalizedCategoryNameWithCorrectNameIsSuccessed() {
        let categoryEngName = "Sendtoallusers"
        let expectedRuName = "Для всех".uppercased()
        
        let result = try? viewModel.getLocalizedCategoryName(engName: categoryEngName).toBlocking().first()
        
        XCTAssertEqual(result ?? "", expectedRuName)
    }
    
    // тест для провальных тестов
    func testGetLocalizedCategoryNameWithIncorrectNameIsEmptyString() {
        let categoryEngName = "Random Name"
        let expectedRuName = ""
        
        let result = try? viewModel.getLocalizedCategoryName(engName: categoryEngName).toBlocking().first()
        
        XCTAssertEqual(result ?? "", expectedRuName)
    }
    
    
    // 1. remove implementation of getLocalizedCategoryName
    // 2. start this test and take screenshot that this test is failed
    // 3. write bad implementation
    // 4. run this test and take screenshot that this test is successed
    // 5. paste first implementation of function back (like refactoring)
    func testGetPostDateWithWithCorrectDateIsSuccessed() {
        let myBirthdayTimestamp = 1568815200            // 18.09.1999
        let expectedDate = "09-18-19"                   // mm-dd-yy
        
        let resultDate = viewModel.getPostDate(timestamp: myBirthdayTimestamp)
        
        XCTAssertEqual(resultDate, expectedDate)
    }
    
    // тест для провальных тестов
    func testGetPostDateWithWithIncorrectDateIsEmptyString() {
        let minIntValue = Int.min
        let expectedDate = ""
        
        let resultDate = viewModel.getPostDate(timestamp: minIntValue)
        
        XCTAssertEqual(resultDate, expectedDate)
    }
    
    
    // 1. remove implementation of getLocalizedCategoryName
    // 2. start this test and take screenshot that this test is failed
    // 3. write bad implementation
    // 4. run this test and take screenshot that this test is successed
    // 5. paste first implementation of function back (like refactoring)
    func testGetHashtagsFromStringIsCorrect() {
        let text = "The #text with #TAG"
        let expectedTags = ["#text", "#TAG"]
        
        let result = text.hashtags()
        
        XCTAssertEqual(result, expectedTags)
    }
    
    func testGetHashtagsFromEmptyStringIsEmptyArray() {
        let text = ""
        let expectedTags: [String] = []
        
        let result = text.hashtags()
        
        XCTAssertEqual(result, expectedTags)
    }
}
