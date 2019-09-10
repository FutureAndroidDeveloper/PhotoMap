//
//  CoreDataService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/27/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import RxSwift

class CoreDataService {
    private let appDelegate: AppDelegate!
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func save(postAnnotation: PostAnnotation) -> Completable {
        // save post to Core Data
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            let managedContext = self.appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Post", in: managedContext)!
            let post = NSManagedObject(entity: entity, insertInto: managedContext)
            
            post.setValue(postAnnotation.category , forKey: "category")
            post.setValue(postAnnotation.date, forKey: "date")
            post.setValue(postAnnotation.imageUrl, forKey: "imageUrl")
            post.setValue(postAnnotation.coordinate.latitude, forKey: "latitude")
            post.setValue(postAnnotation.coordinate.longitude, forKey: "longitude")
            post.setValue(postAnnotation.postDescription, forKey: "postDescription")
            
            do {
                try managedContext.save()
                completable(.completed)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                completable(.error(error))
                completable(.completed)
            }
            
            return Disposables.create()
        }
    }
    
    func fetch(without categories: [String] = []) -> Observable<[PostAnnotation]> {
        return Observable.create { [weak self] observer  in
            guard let self = self else { return Disposables.create() }
            
            let managedContext = self.appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Post")
            var subpredicates = [NSPredicate]()
            
            categories.forEach { category in
                subpredicates.append(NSPredicate(format: "category != %@", "\(category.uppercased())"))
            }
            let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
            fetchRequest.predicate = predicateCompound
            var posts = [PostAnnotation]()
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                
                for result in results {
                    let post = PostAnnotation(date: result.value(forKey: "date") as! Int,
                                              category: result.value(forKey: "category") as! String,
                                              postDescription: result.value(forKey: "postDescription") as? String,
                                              imageUrl: result.value(forKey: "imageUrl") as? String,
                                              coordinate: CLLocationCoordinate2D(latitude:result.value(forKey: "latitude") as! Double,
                                                                                 longitude: result.value(forKey: "longitude") as! Double))
                    posts.append(post)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                observer.onError(error)
                observer.onCompleted()
            }

            observer.onNext(posts)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func isUnique(postAnnotation: PostAnnotation) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let myRequest = NSFetchRequest<NSManagedObject>(entityName: "Post")
        myRequest.predicate = NSPredicate(format: "imageUrl = %@", postAnnotation.imageUrl!)
        
        do {
            let result = try context.fetch(myRequest)
            return result.isEmpty
        } catch let error {
            print(error)
            return false
        }
    }
}
