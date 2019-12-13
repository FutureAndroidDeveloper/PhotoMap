//
//  MockFBNotification.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class MockFBNotification: FirebaseNotification {
    func postDidRemoved() -> Observable<PostAnnotation> {
        return .empty()
    }
    
    func categoryDidRemoved() -> Observable<PhotoCategory> {
        return .empty()
    }
    
    func categoryDidAdded() -> Observable<PhotoCategory> {
        return .empty()
    }
}
