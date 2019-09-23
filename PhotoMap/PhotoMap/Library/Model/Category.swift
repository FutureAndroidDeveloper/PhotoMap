//
//  Category.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

struct Category: Codable {
    let hexColor: String
    let engName: String
    let ruName: String
    
    private enum CodingKeys: String, CodingKey {
        case hexColor
        case engName
        case ruName
    }
}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.engName == rhs.engName &&
            lhs.ruName == rhs.ruName &&
            lhs.hexColor == rhs.hexColor
    }
}

extension Category: CustomStringConvertible {
    var description: String {
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": return self.ruName
            default: return self.engName
            }
        }
        return self.engName
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        var result = false
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": result = lhs.ruName < rhs.ruName
            default: result = lhs.engName < rhs.engName
            }
        }
        return result
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than or equal to that of the second argument.
    static func <= (lhs: Category, rhs: Category) -> Bool {
        var result = false
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": result = lhs.ruName <= rhs.ruName
            default: result = lhs.engName <= rhs.engName
            }
        }
        return result
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than or equal to that of the second argument.
    static func >= (lhs: Category, rhs: Category) -> Bool {
        var result = false
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": result = lhs.ruName >= rhs.ruName
            default: result = lhs.engName >= rhs.engName
            }
        }
        return result
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is greater than that of the second argument.
    static func > (lhs: Category, rhs: Category) -> Bool {
        var result = false
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": result = lhs.ruName > rhs.ruName
            default: result = lhs.engName > rhs.engName
            }
        }
        return result
    }
}
