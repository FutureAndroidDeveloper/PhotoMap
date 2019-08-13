//
//  Post.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    
    var categoryImage: UIImage {
        return UIImage(named: category.lowercased())!
    }
    
    let image: UIImage
    let date: Int
    let category: String
    let postDescription: String?
    var coordinate: CLLocationCoordinate2D
    
    init(image: UIImage, date: Int, category: String,postDescription: String?,
         coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        self.image = image
        self.date = date
        self.category = category
        self.postDescription = postDescription
        self.coordinate = coordinate
        super.init()
    }
}
