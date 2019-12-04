//
//  PhotoLibraryService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/1/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class LocationService: Authorizing {
    let locationManager = CLLocationManager()    
    
    var authorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
                    || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}

