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

@testable import PhotoMap

class FirebaseDownloadTests: XCTestCase {
    var firebaseDownload: FirebaseDownloading!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseDownload = FirebaseDownloadDelegate()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        firebaseDownload = nil
    }

    // MARK: - downloadUserPosts Tests
    func testDownloadUserPosts() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
