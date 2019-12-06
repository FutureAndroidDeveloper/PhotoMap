//
//  FirebaseError.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation

enum FirebaseError: Error {
    case badImage
    case badJson
    case badCategory
    case serializationError
}

extension FirebaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badImage:
            return NSLocalizedString("Unkown Image", comment: "FirebaseError")
        case .badCategory:
            return NSLocalizedString("Unkown category", comment: "FirebaseError")
        case .badJson:
            return NSLocalizedString("Unkown JSON", comment: "FirebaseError")
        case .serializationError:
            return NSLocalizedString("Serialization Error", comment: "FirebaseError")
        }
    }
}
