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
}

class DateService {
    
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private let numberFormatter = NumberFormatter()
    
    func getLongDate(timestamp: Int, modifier: DateModifier) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let components = calendar.dateComponents([.day], from: date)
        numberFormatter.numberStyle = .ordinal
        
        let ordinalDay = numberFormatter.string(from: components.day! as NSNumber)
        
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.dateFormat = "MMMM '\(ordinalDay!)', yyyy '\(modifier.rawValue)' h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func getShortDate(timestamp: Int) -> String? {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }
}
