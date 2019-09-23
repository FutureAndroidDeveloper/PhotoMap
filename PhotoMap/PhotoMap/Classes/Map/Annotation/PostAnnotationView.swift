//
//  PostViews.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/7/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import MapKit

extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIImage.resize(image: image, targetSize: scaledSize)
    }
}

class PostAnnotationView: MKAnnotationView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == nil {
            self.superview?.bringSubviewToFront(self)
        }
        
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside = rect.contains(point)
        
        if !isInside {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        
        return isInside
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let post = newValue as? PostAnnotation else { return }
            canShowCallout = false
            centerOffset = CGPoint(x: 0, y: -22)
            let back = R.image.categoryBack()
            let main = R.image.categoryBack()?.tintWithColor(color: UIColor(hex: post.hexColor)!)
            let newSize = CGSize(width: 40, height: 40)   // set this to what you need
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            back!.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            main!.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            image = newImage
            clusteringIdentifier = MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        }
    }
}

extension UIImage {
    func tintWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()!
        
        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
