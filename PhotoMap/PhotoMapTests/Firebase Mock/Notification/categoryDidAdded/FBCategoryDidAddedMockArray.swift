//
//  FBCategoryDidAddedMockArray.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class FBCategoryDidAddedMockArray: MockFBNotification {
    var categories: [PhotoCategory]!
    
    init(categories: [PhotoCategory]) {
        self.categories = categories
    }
    
    override func categoryDidAdded() -> Observable<PhotoCategory> {
        return Observable.from(categories)
    }
}
