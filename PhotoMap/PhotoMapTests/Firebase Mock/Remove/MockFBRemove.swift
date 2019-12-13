//
//  MockFBRemove.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class MockFBRemove: FirebaseRemovable {
    func removeIncorrectPost(_ post: PostAnnotation) -> Observable<PostAnnotation> {
        return .empty()
    }
    
    func removeCategory(_ category: PhotoCategory) -> Observable<PhotoCategory> {
        return .empty()
    }
    
    func removeOldPost(posts: [PostAnnotation]) -> Observable<[PostAnnotation]> {
        return .empty()
    }
}
