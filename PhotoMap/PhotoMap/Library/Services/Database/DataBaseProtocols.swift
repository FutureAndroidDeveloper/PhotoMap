//
//  CoreDataService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/27/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import RxSwift

enum CoreDataError: Error {
    case duplicate(type: Any)
}

extension CoreDataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .duplicate(let type):
            return "\(R.string.localizable.dataBaseDuplicate()) for \(type)"
        }
    }
}

/// CRUD
protocol DataBase {
    func save(postAnnotation: PostAnnotation) -> Completable
    func save(category: PhotoCategory) -> Completable
    
    func fetch(without categories: [String]) -> Observable<[PostAnnotation]>
    func fetch() -> Observable<[PhotoCategory]>
    
    func removePostFromCoredata(_ post: PostAnnotation) -> Observable<PostAnnotation?>
    func removeCategoryFromCoredata(_ category: PhotoCategory) -> Observable<PhotoCategory?>

    func isUnique(postAnnotation: PostAnnotation) -> Bool
    func isUnique(category: PhotoCategory) -> Bool
}

extension DataBase {
    // optional methods
    func isUnique(postAnnotation: PostAnnotation) -> Bool { return false }
    func isUnique(category: PhotoCategory) -> Bool { return false }
}
