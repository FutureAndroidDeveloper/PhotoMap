//
//  FirebaseRemoveDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseDatabase.FIRDataSnapshot
import RxFirebaseDatabase

// @discardableResult
protocol FirebaseRemovable {
    func removeIncorrectPost(_ post: PostAnnotation) -> Observable<PostAnnotation>
    func removeCategory(_ category: PhotoCategory) -> Observable<PhotoCategory>
    func removeOldPost(posts: [PostAnnotation]) -> Observable<[PostAnnotation]>
}

class FirebaseRemoveDelegate: FirebaseRemovable {
    private let bag = DisposeBag()
    private let references = FirebaseReferences.shared
    
    func removeIncorrectPost(_ post: PostAnnotation) -> Observable<PostAnnotation> {
        return references.database.queryOrdered(byChild: "imageUrl").queryEqual(toValue: post.imageUrl!).rx
            .observeSingleEvent(.value)
            .map { snapshot -> String in
                var modelID = ""
                for snap in snapshot.children {
                    modelID = (snap as! DataSnapshot).key
                    break
                }
                return modelID
            }
            .flatMap { [weak self] childKey -> Observable<DatabaseReference> in
                guard let self = self else { return .empty() }
                return self.references.database.child(childKey).rx.removeValue()
            }
            .flatMap { [weak self] _ -> Completable in
                guard let self = self else { return .empty() }
                return self.removeImage(for: post)
            }
            .map { _ in post }
            .take(1)
    }
    
    func removeCategory(_ category: PhotoCategory) -> Observable<PhotoCategory> {
        return references.database.root.child("categories")
            .queryOrdered(byChild: "hexColor")
            .queryEqual(toValue: category.hexColor).rx
            .observeEvent(.value)
            .flatMap { [weak self] snapshot -> Observable<DatabaseReference> in
                guard let self = self else { return .empty() }
                guard let value = snapshot.value as? [String: Any] else {
                    return .error(FirebaseError.badCategory)
                }
                return self.references.database.root.child("categories")
                    .child(value.keys.first!).rx.removeValue()
            }
            .map { _ in category }
            .take(1)
    }
    
    // returns posts from FB using posts from Core Data for comparison
    func removeOldPost(posts: [PostAnnotation]) -> Observable<[PostAnnotation]> {
        return Observable.from(posts)
            .flatMap { [weak self] post -> Observable<PostAnnotation> in
                guard let self = self else { return .empty() }
                return self.searchPostInBase(post: post)
            }
            .toArray()
            .asObservable()
    }
    
    /// remove image from FB
    private func removeImage(for post: PostAnnotation) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                completable(.error(FirebaseError.badImage))
                return Disposables.create()
            }
            let mainString = post.imageUrl!.split(separator: "/").last!
            let startIndex = mainString.index(mainString.startIndex, offsetBy: post.category.count + 3)
            let endIndex = mainString.firstIndex(of: "?")!
            let imageName = String(mainString[startIndex..<endIndex])
            
            self.references.storage.child(post.category.lowercased()).child(imageName).delete { error in
                guard let error = error else {
                    completable(.completed)
                    return
                }
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    /// get post from Firebase based on post from Coredata
    private func searchPostInBase(post: PostAnnotation) -> Observable<PostAnnotation>{
        return references.database.queryOrdered(byChild: "imageUrl")
            .queryEqual(toValue: post.imageUrl!).rx
            .observeSingleEvent(.value)
            .compactMap { $0.value as? [String: Any] }
            .map { _ in post }
            .take(1)
    }
}
