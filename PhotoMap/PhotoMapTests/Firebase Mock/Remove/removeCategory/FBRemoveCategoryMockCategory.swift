//
//  FBRemoveCategoryMockCategory.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class FBRemoveCategoryMockCategory: MockFBRemove {
    override func removeCategory(_ category: PhotoCategory) -> Observable<PhotoCategory> {
        return .just(category)
    }
}
