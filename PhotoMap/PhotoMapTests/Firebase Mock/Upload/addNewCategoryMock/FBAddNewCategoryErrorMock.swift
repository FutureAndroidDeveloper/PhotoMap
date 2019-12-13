//
//  FBAddNewCategoryMock.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class FBAddNewCategoryErrorMock: MockFBUpload {
    override func addNewCategory(_ category: PhotoCategory) -> Completable {
        return .error(MockFBError.addNewCategoryError)
    }
}
