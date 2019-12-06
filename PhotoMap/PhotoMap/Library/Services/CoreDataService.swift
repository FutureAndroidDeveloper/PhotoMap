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

enum CoreDataError: Error {
    case duplicate
}

class CoreDataService {
    private let appDelegate: AppDelegate!
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func save(postAnnotation: PostAnnotation) -> Completable {
        // save post to Core Data
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            if !self.isUnique(postAnnotation: postAnnotation) {
                completable(.completed)
                 return Disposables.create()
            }
            let managedContext = self.appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Post", in: managedContext)!
            let post = NSManagedObject(entity: entity, insertInto: managedContext)
            
            post.setValue(postAnnotation.category , forKey: "category")
            post.setValue(postAnnotation.hexColor, forKey: "hexColor")
            post.setValue(postAnnotation.date, forKey: "date")
            post.setValue(postAnnotation.imageUrl, forKey: "imageUrl")
            post.setValue(postAnnotation.coordinate.latitude, forKey: "latitude")
            post.setValue(postAnnotation.coordinate.longitude, forKey: "longitude")
            post.setValue(postAnnotation.postDescription, forKey: "postDescription")
            post.setValue(postAnnotation.userID, forKey: "userId")
            
            do {
                try managedContext.save()
                completable(.completed)
            } catch let error as NSError {
                completable(.error(error))
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
    func save(category: PhotoCategory) -> Completable {
        // save new category to Core Data
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            if !self.isUnique(category: category) {
                completable(.error(CoreDataError.duplicate))
                return Disposables.create()
            }
            
            let managedContext = self.appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Categories", in: managedContext)!
            let newCategory = NSManagedObject(entity: entity, insertInto: managedContext)
            newCategory.setValue(category.hexColor , forKey: "hexColor")
            newCategory.setValue(category.engName, forKey: "engName")
            newCategory.setValue(category.ruName, forKey: "ruName")
            
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
                                              hexColor: result.value(forKey: "hexColor") as! String,
                                              category: result.value(forKey: "category") as! String,
                                              postDescription: result.value(forKey: "postDescription") as? String,
                                              imageUrl: result.value(forKey: "imageUrl") as? String,
                                              userId: result.value(forKey: "userId") as! String,
                                              coordinate: CLLocationCoordinate2D(latitude:result.value(forKey: "latitude") as! Double,
                                                                                 longitude: result.value(forKey: "longitude") as! Double))
                    posts.append(post)
                }
            } catch let error as NSError {
                observer.onError(error)
                observer.onCompleted()
            }
            observer.onNext(posts)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetch() -> Observable<[PhotoCategory]> {
        return Observable.create { [weak self] observer  in
            guard let self = self else { return Disposables.create() }
            let managedContext = self.appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
            var categories = [PhotoCategory]()
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                for result in results {
                    let category = PhotoCategory(hexColor: result.value(forKey: "hexColor") as! String,
                                            engName: result.value(forKey: "engName") as! String,
                                            ruName: result.value(forKey: "ruName") as! String)
                    categories.append(category)
                }
            } catch let error as NSError {
                observer.onError(error)
            }
            observer.onNext(categories)
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
    
    func isUnique(category: PhotoCategory) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        var subpredicates = [NSPredicate]()
        subpredicates.append(NSPredicate(format: "hexColor = %@", "\(category.hexColor)"))
        subpredicates.append(NSPredicate(format: "engName = %@", "\(category.engName)"))
        subpredicates.append(NSPredicate(format: "ruName = %@", "\(category.ruName)"))
        let predicateCompound = NSCompoundPredicate(type: .or, subpredicates: subpredicates)
        fetchRequest.predicate = predicateCompound
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.isEmpty
        } catch let error {
            print(error)
            return false
        }
    }
    
    func removePostFromCoredata(_ post: PostAnnotation) -> PostAnnotation? {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Post")
        let predicate = NSPredicate(format: "imageUrl == %@", post.imageUrl ?? "")
        fetchRequest.predicate = predicate
        var removedPost: PostAnnotation?
        
        do {
            let posts = try context.fetch(fetchRequest)
            
            for fetchedPost in posts {
                context.delete(fetchedPost)
                removedPost = post
            }
            try context.save()
        } catch {
            // TODO: - Handle error (show in allert)
            print(error)
            return nil
            
        }
        
        return removedPost
    }
    
    func removeCategoryFromCoredata(_ category: PhotoCategory) {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        let predicate = NSPredicate(format: "hexColor == %@", category.hexColor)
        fetchRequest.predicate = predicate
        
        do {
            let categories = try context.fetch(fetchRequest)
            for oldCategory in categories {
                context.delete(oldCategory)
            }
            try context.save()
        } catch {
            print(error)
        }
    }

}
