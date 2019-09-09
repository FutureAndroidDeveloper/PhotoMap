//
//  PhotoMapTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 9/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking
import Photos

@testable import PhotoMap

class PhotoMapTests: XCTestCase {
    var service: PhotoLibraryService!
    var scheduler: TestScheduler!
    var bag = DisposeBag()

    override func setUp() {
        service = PhotoLibraryService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAuthorizationStatus() throws {
        let isAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        XCTAssertEqual(try service.authorized.toBlocking().first(), isAuthorized)
    }
}
