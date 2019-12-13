//
//  CategoryMarkerViewTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest

@testable import PhotoMap

class CategoryMarkerViewTests: XCTestCase {
    
    override func setUp() { }

    override func tearDown() { }

    func testCreateDefaultMarkerViewIsBlack() {
        let expectedColor: UIColor = .black
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        let marker = CategoryMarker(frame: rect)
        
        XCTAssertEqual(marker.color, expectedColor)
    }
    
    func testChangeViewColor() {
        let expectedColor: UIColor = .green
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let marker = CategoryMarker(frame: rect)
        marker.color = .green
        
        XCTAssertEqual(marker.color, expectedColor)
    }
}
