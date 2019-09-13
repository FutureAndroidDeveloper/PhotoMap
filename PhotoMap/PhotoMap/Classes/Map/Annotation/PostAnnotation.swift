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

class PostAnnotation: NSObject, MKAnnotation, Codable {
    var categoryImage: UIImage {
        return UIImage(named: "Categories/" + category.lowercased())!
    }
    
    var image: UIImage?
    let date: Int
    var category: String
    let postDescription: String?
    var imageUrl: String?
    var coordinate: CLLocationCoordinate2D
    
    private enum CodingKeys: String, CodingKey {
        case image
        case date
        case category
        case postDescription
        case coordinate
        case imageUrl
    }
    
    init(image: UIImage, date: Int, category: String, postDescription: String?,
         coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        self.image = image
        self.date = date
        self.category = category
        self.postDescription = postDescription
        self.coordinate = coordinate
        super.init()
    }
    
    init(date: Int, category: String, postDescription: String?,
         imageUrl: String?,coordinate: CLLocationCoordinate2D) {
        self.date = date
        self.category = category
        self.postDescription = postDescription
        self.coordinate = coordinate
        self.imageUrl = imageUrl
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try? container.decode(Data.self, forKey: .image)
        image = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData ?? Data()) as? UIImage ?? UIImage()
        date = try container.decode(Int.self, forKey: .date)
        category = try container.decode(String.self, forKey: .category)
        postDescription = try container.decode(String.self, forKey: .postDescription)
        coordinate = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinate)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let imageData = try NSKeyedArchiver.archivedData(withRootObject: image!, requiringSecureCoding: false)
        try container.encode(imageData, forKey: .image)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encode(postDescription, forKey: .postDescription)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(imageUrl, forKey: .imageUrl)
    }
}

extension PostAnnotation {
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PostAnnotation else { return false }
        return self.imageUrl == object.imageUrl
    }
    
    func setLocalizedCategoryKey() {
        category = category.localizedKey().uppercased()
    }
}

extension CLLocationCoordinate2D: Codable {
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
