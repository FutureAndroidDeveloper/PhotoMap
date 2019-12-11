//
//  ApplicationUser.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/10/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

struct ApplicationUser: Codable {
    var isAdmin: Bool
    let id: String
    let email: String
    
    private enum CodingKeys: String, CodingKey {
        case isAdmin
        case id
        case email
    }
    
    init(isAdmin: Bool = false, id: String, email: String) {
        self.isAdmin = isAdmin
        self.id = id
        self.email = email
    }
}

extension ApplicationUser: Equatable {
    static func ==(lhs: ApplicationUser, rhs: ApplicationUser) -> Bool {
        return lhs.email == rhs.email
    }
    
    static func != (lhs: ApplicationUser, rhs: ApplicationUser) -> Bool {
        return lhs.email != rhs.email
    }
}
