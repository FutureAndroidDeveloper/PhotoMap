//
//  DateService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

enum DateModifier: String {
    case at = "at"
    case dash = "-"
    
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

enum YearLength: String {
    case long = "yyyy"
    case short = "yy"
}

class DateService {
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private let numberFormatter = NumberFormatter()
    
    init() {
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    func getLongDate(timestamp: Int, modifier: DateModifier) -> String {
        if Double(timestamp) > Date().timeIntervalSince1970 {
            return String()
        }
        
        var ordinalDay: String?
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let components = calendar.dateComponents([.day], from: date)
        numberFormatter.numberStyle = .ordinal
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                ordinalDay = "\(components.day!)" + "е"
            default:
                numberFormatter.locale = Locale(identifier: R.string.localizable.ordinalNumber())
                ordinalDay = numberFormatter.string(from: components.day! as NSNumber)
            }
        }
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.dateFormat = """
        LLLL '\(ordinalDay!)', yyyy '\(modifier.localizedString())' \(R.string.localizable.timeFormat())
        """
        
        let dateString = dateFormatter.string(from: date)
        let month = dateString.split(separator: " ").first ?? ""
        return dateString.replacingOccurrences(of: month, with: month.capitalized)
    }
    
    func getShortDate(timestamp: Int, yearLength: YearLength) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        dateFormatter.dateFormat = "LL-dd-\(yearLength.rawValue)"
        return dateFormatter.string(from: date)
    }
    
    func getMonthAndYear(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        dateFormatter.dateFormat = "LLLL yyyy"
        return dateFormatter.string(from: date).capitalized
    }
}
