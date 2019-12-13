//
//  MockUniqueCategoryAlwaysTrue.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class MockUniqueCategoryAlwaysTrue: MockCoreData {
    override func isUnique(category: PhotoCategory) -> Bool {
        return true
    }
}
