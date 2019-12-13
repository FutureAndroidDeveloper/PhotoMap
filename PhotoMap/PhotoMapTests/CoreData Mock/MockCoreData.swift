//
//  MockCoreData.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

enum MockCDError: Error {
    case duplicateCategory
}

extension MockCDError: LocalizedError {
    var errorDescription: String? {
        switch self {
        default:
            return "Mock Error"
        }
    }
}

class MockCoreData: DataBase {
    func save(postAnnotation: PostAnnotation) -> Completable {
        return .empty()
    }
    
    func save(category: PhotoCategory) -> Completable {
        return .empty()
    }
    
    func fetch(without categories: [String]) -> Observable<[PostAnnotation]> {
        return .empty()
    }
    
    func fetch() -> Observable<[PhotoCategory]> {
        return .empty()
    }
    
    func removePostFromCoredata(_ post: PostAnnotation) -> Observable<PostAnnotation?> {
        return .empty()
    }
    
    func removeCategoryFromCoredata(_ category: PhotoCategory) -> Observable<PhotoCategory?> {
        return .empty()
    }
    
    func isUnique(postAnnotation: PostAnnotation) -> Bool {
        return false
    }
    
    func isUnique(category: PhotoCategory) -> Bool {
        return false
    }
}
