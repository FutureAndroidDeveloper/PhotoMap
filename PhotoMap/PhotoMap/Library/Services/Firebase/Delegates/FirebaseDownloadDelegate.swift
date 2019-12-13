//
//  FirebaseDownloadDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import MapKit.MKGeometry
import GeoFire

protocol FirebaseDownloading {
    func downloadUserPosts() -> Observable<[PostAnnotation]>
    func download(in region: MKCoordinateRegion, uncheckedCategories categories: [String]) -> Observable<[PostAnnotation]>
    func getCategories() ->Observable<[PhotoCategory]>
}

class FirebaseDownloadDelegate: FirebaseDownloading {
    private let bag = DisposeBag()
    private let references = FirebaseReferences.shared
    
    /// download all posts created by current user
    func downloadUserPosts() -> Observable<[PostAnnotation]> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            // Query posts created by current user
            let userPostsQuery = self.references.database.queryOrdered(byChild: "userID")
                .queryEqual(toValue: self.references.auth.currentUser!.uid)
            
            userPostsQuery.observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [AnyHashable: [String: Any]] else { return }
                let jsonPosts = value.map { $1 }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonPosts, options: [])
                    let posts = try JSONDecoder().decode([PostAnnotation].self, from: jsonData)
                    observer.onNext(posts)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            })
            return Disposables.create { userPostsQuery.removeAllObservers() }
        }
    }
    
    /// download all posts that inside map region
    func download(in region: MKCoordinateRegion, uncheckedCategories categories: [String]) -> Observable<[PostAnnotation]> {
        return Observable.create { [weak self] observer  in
            guard let self = self else { return Disposables.create() }
            let zoomDelta = self.references.zoomDelta
            if region.span.latitudeDelta > zoomDelta && region.span.longitudeDelta > zoomDelta {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Query location by region
            let regionQuery = GeoFire(firebaseRef: self.references.database).query(with: region)
            regionQuery.observe(.keyEntered, with: { [weak self] key, _ in
                guard let self = self else {
                    observer.onCompleted()
                    return
                }
                self.references.database.child(key).observe(.value, with: { snapshot in
                    guard let value = snapshot.value as? [String: Any] else { return }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let post = try JSONDecoder().decode(PostAnnotation.self, from: jsonData)
                        
                        if !categories.contains(post.category.lowercased()) {
                            observer.onNext([post])
                            observer.onCompleted()
                        } else {
                            observer.onNext([])
                            observer.onCompleted()
                        }
                    } catch {
                        observer.onError(error)
                    }
                })
            })
            return Disposables.create { regionQuery.removeAllObservers() }
        }
    }
    
    /// get all categories from data base
    func getCategories() -> Observable<[PhotoCategory]> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.references.database.root
                .child("categories")
                .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [AnyHashable: [String: Any]] else { return }
                let jsonCategories = value.map { $1 }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonCategories, options: [])
                    let categories = try JSONDecoder().decode([PhotoCategory].self, from: jsonData)
                    observer.onNext(categories)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
}
