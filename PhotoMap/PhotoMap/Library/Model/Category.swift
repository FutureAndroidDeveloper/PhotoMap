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
