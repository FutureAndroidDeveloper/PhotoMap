//
//  MockRemoveCategoryFromCoredata.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class MockRemoveCategoryFromCoredata: MockCoreData {
    override func removeCategoryFromCoredata(_ category: PhotoCategory) -> Observable<PhotoCategory?> {
        return Observable.just(category)
    }
}
