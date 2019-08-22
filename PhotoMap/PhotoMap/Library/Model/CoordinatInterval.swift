//
//  CoordinatInterval.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/21/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation

struct CoordinateInterval {
    var beginLatitude: CLLocationDegrees
    var endLatitude: CLLocationDegrees
    var beginLongitude: CLLocationDegrees
    var endLongitude: CLLocationDegrees
    var latitudeDelta: Double
    var longitudeDelta: Double
}
