//
//  StoryboardInitializable.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

/// Lets the oppotunity to create View Controller from storyboard programmatically.
protocol StoryboardInitializable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyBoard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyBoard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
