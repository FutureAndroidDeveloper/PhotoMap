//
//  DateService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

class DateService {
    
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private let numberFormatter = NumberFormatter()
    
    func getCurrentDate() -> String {
        return getFormattedDate(date: Date())
    }
    
    func getFormattedDate(date: Date) -> String {
        let components = calendar.dateComponents([.day], from: date)
        numberFormatter.numberStyle = .ordinal
        
        let ordinalDay = numberFormatter.string(from: components.day! as NSNumber)
        
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.dateFormat = "MMMM '\(ordinalDay!)', yyyy - h:mm a"
        return dateFormatter.string(from: date)
    }
}
