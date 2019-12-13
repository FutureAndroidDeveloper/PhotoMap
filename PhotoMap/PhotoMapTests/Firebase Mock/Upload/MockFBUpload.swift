//
//  MockFBUpload.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseStorage.FIRStorageMetadata

@testable import PhotoMap

enum MockFBError: Error {
    case addNewCategoryError
}

extension MockFBError: LocalizedError {
    var errorDescription: String? {
        switch self {
        default:
            return "Mock Error"
        }
    }
}

class MockFBUpload: FirebaseUploading {
    func upload(post: PostAnnotation) -> Completable {
        return .empty()
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata) -> Observable<URL> {
        return .empty()
    }
    
    func addNewCategory(_ category: PhotoCategory) -> Completable {
        return .empty()
    }
    
    func save(_ user: ApplicationUser) -> Completable {
        return .empty()
    }
}
