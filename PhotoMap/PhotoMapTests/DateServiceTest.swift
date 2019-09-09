//
//  DateServiceTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 9/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest

@testable import PhotoMap

class DateServiceTest: XCTestCase {
    var service: DateService!
    var birthdayTimestamp: Int!
    
    override func setUp() {
        service = DateService()
        birthdayTimestamp = 1568815200
    }
    
    override func tearDown() {
        service = nil
    }
    
    func testLongDateWithAtModifierFormat() {
        let atModifier = DateModifier.at
        var exceptedFormat = String()
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                exceptedFormat = "Сентябрь 18e, 2019 в 14:00"
            default:
                exceptedFormat = "September 18th, 2019 at 2:00 pm"
            }
        }
        
        let formattedString = service.getLongDate(timestamp: birthdayTimestamp, modifier: atModifier)
        XCTAssertEqual(formattedString, exceptedFormat)
    }
    
    func testLongDateWithDashModifierFormat() {
        let atModifier = DateModifier.dash
        var exceptedFormat = String()
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                exceptedFormat = "Сентябрь 18e, 2019 - 14:00"
            default:
                exceptedFormat = "September 18th, 2019 - 2:00 pm"
            }
        }
        
        let formattedString = service.getLongDate(timestamp: birthdayTimestamp, modifier: atModifier)
        XCTAssertEqual(formattedString, exceptedFormat)
    }
    
    func testShortDateWithLongYearFormat() {
        let longYear = YearLength.long
        let formattedString = service.getShortDate(timestamp: birthdayTimestamp, yearLength: longYear)
        
        XCTAssertEqual(formattedString, "09-18-2019")
    }
    
    func testShortDateWithShortYearFormat() {
        let shortYear = YearLength.short
        let formattedString = service.getShortDate(timestamp: birthdayTimestamp, yearLength: shortYear)
        
        XCTAssertEqual(formattedString, "09-18-19")
    }
    
    
    func testMonthAndYearFormat() {
        var exceptedFormat = String()
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                exceptedFormat = "Сентябрь 2019"
            default:
                exceptedFormat = "September 2019"
            }
        }
        
        let formattedString = service.getMonthAndYear(timestamp: birthdayTimestamp)
        XCTAssertEqual(formattedString, exceptedFormat)
    }
}
