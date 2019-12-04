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
    
    func testMinInt() {
        
        // 10_000_000 - бред типа год 27075
        // 10_000_000_0 - год 954
        let num = -62_135_769_600
        print(service.getLongDate(timestamp: num, modifier: .at))
        print(Int.min / 15_000_000_0)
        
        
        // Январь 1е, 0001 в 00:00
        XCTAssert(true)
    }
    
    // верная начальная граница
    func testGetLongDateWithBeginningOfOurEraIsValid() {
        let startOfEra = -62_135_769_600
        let expectedDate = "Январь 1е, 0001 в 00:00"
        
        let result = service.getLongDate(timestamp: startOfEra, modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    
    // верная конечная граница
    func testGetLongDateWithCurrentDateIsValid() {
        let currentDate = Date().timeIntervalSince1970
        let calendar = Calendar.current
        let date = Date()
        
        let components = calendar.dateComponents([.day, .hour, .minute], from: date)
        let time = String(format: "%02d:%02d", components.hour! - 3, components.minute!)
        let expectedDate = String(format: "Ноябрь %02dе, 2019 в \(time)", components.day!)
        
        let result = service.getLongDate(timestamp: Int(currentDate), modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    // верное эквивалентное
    func testGetLongDateWithZeroIsValid() {
        let expectedDate = "Январь 1е, 1970 в 00:00"
        
        let result = service.getLongDate(timestamp: 0, modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    

    // верное эквивалентное
    func testGetLongDateWithMinusOneIsValid() {
        let expectedDate = "Декабрь 1е, 1969 в 23:59"
        
        let result = service.getLongDate(timestamp: -1, modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    // неверная граница в далеком будущем
    func testGetLongDateWithMaxIntIsEmptyString() {
        let expectedDate = ""
        
        let result = service.getLongDate(timestamp: Int.max, modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    
    // неверный эквивалент в будущем
    func testGetLongDateWithFutureDateIsEmptyString() {
        let dateInTheFuture = Date().timeIntervalSince1970 * 2
        let expectedDate = ""
        
        let result = service.getLongDate(timestamp: Int(dateInTheFuture), modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    
    // неверная граница в далеком прошлом
    func testGetLongDateWithMinIntIsEmptyString() {
        let expectedDate = ""
        
        let result = service.getLongDate(timestamp: Int.min, modifier: .at)
        
        XCTAssertEqual(result, expectedDate)
    }
    
    
    // неверный эквивалент в прошлом
//    func testGetLongDateWithPastDateIsEmptyString() {
//        let dateInTheFuture = Date().timeIntervalSince1970 * -20
//        let expectedDate = ""
//
//        let result = service.getLongDate(timestamp: Int(dateInTheFuture), modifier: .at)
//
//        XCTAssertEqual(result, expectedDate)
//    }
    
    func testLongDateWithAtModifierFormat() {
        let atModifier = DateModifier.at
        var exceptedFormat = String()
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                exceptedFormat = "Сентябрь 18е, 2019 в 14:00"
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
                exceptedFormat = "Сентябрь 18е, 2019 - 14:00"
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
