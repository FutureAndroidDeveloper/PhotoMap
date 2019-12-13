//
//  FBCategoryDidRemovedMockCategory.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class FBCategoryDidRemovedMockCategory: MockFBNotification {
    var category: PhotoCategory!
    var categories: [PhotoCategory]!
    
    init(categories: [PhotoCategory], removedCategory: PhotoCategory) {
        self.categories = categories
        self.category = removedCategory
    }
    
    override func categoryDidRemoved() -> Observable<PhotoCategory> {
        return Observable.just(category)
            .timeout(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
    }
    
    override func categoryDidAdded() -> Observable<PhotoCategory> {
        return Observable.from(categories)
    }
}
