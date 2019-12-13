//
//  CheckBoxViewTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest

@testable import PhotoMap

class CheckBoxViewTests: XCTestCase {
    var checkBox: CheckBox!

    override func setUp() {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        checkBox = CheckBox(frame: frame)
    }

    override func tearDown() {
        checkBox.delegate = nil
        checkBox = nil
    }

    
    // MARK: - isChecked Tests
    func testIsCheckedByDefaultIsTrue() {
        let expectedResult = true
        XCTAssertEqual(checkBox.isChecked, expectedResult)
    }
}
