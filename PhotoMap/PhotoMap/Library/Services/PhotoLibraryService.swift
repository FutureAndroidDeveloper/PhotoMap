//
//  PhotoLibraryService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/1/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import Photos
import RxSwift

protocol Authorizing {
    var authorized: Observable<Bool> { get }
}

class PhotoLibraryService: Authorizing {
    var authorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if PHPhotoLibrary.authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    PHPhotoLibrary.requestAuthorization { newStatus in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}

