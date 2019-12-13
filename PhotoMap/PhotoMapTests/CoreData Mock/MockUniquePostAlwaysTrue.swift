//
//  MockUniquePostAlwaysTrue.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class MockUniquePostAlwaysTrue: MockCoreData {
    override func isUnique(postAnnotation: PostAnnotation) -> Bool {
        return true
    }
}
