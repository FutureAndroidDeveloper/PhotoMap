//
//  MockFBDownload.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

import MapKit.MKGeometry

@testable import PhotoMap

class MockFBDownload: FirebaseDownloading {
    func downloadUserPosts() -> Observable<[PostAnnotation]> {
        return .empty()
    }
    
    func download(in region: MKCoordinateRegion, uncheckedCategories categories: [String]) -> Observable<[PostAnnotation]> {
        return .empty()
    }
    
    func getCategories() -> Observable<[PhotoCategory]> {
        return .empty()
    }
    
}
