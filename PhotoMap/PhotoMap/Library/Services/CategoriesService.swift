//
//  CategoriesService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class CategoriesService {
    private let fileManager: FileManager!
    private let resourcePath: URL!
    private let folderName = "Categories"
    
    init() {
        fileManager = FileManager.default
        resourcePath = URL(string: Bundle.main.resourcePath!)?.appendingPathComponent(folderName)
    }
    
    func getCategories() -> Observable<[String]> {
        var categories = [String]()
        let items = try! fileManager.contentsOfDirectory(atPath: resourcePath!.absoluteString)
        
        for var item in items {
            if let index = item.range(of: ".") {
                let distance = item.distance(from: index.lowerBound, to: item.endIndex)
                item.removeLast(distance)
                categories.append(item)
            }
        }
        return Observable.just(categories.reversed())
    }
}
