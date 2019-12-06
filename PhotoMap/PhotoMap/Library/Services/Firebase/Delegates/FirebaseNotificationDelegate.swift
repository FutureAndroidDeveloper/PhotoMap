//
//  FirebaseNotificationDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

protocol FirebaseNotification {
    func postDidRemoved() -> Observable<PostAnnotation>
    func categoryDidRemoved() -> Observable<PhotoCategory>
    func categoryDidAdded() -> Observable<PhotoCategory>
}

class FirebaseNotificationDelegate: FirebaseNotification {
    private let bag = DisposeBag()
    private let references = FirebaseReferences.shared
    
    func postDidRemoved() -> Observable<PostAnnotation> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.references.database.observe(.childRemoved, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else { return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    let post = try JSONDecoder().decode(PostAnnotation.self, from: jsonData)
                    observer.onNext(post)
                } catch {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    func categoryDidRemoved() -> Observable<PhotoCategory> {
        return references.database.root.child("categories").rx
            .observeEvent(.childRemoved)
            .flatMap { snapshot -> Observable<PhotoCategory> in
                guard let value = snapshot.value as? [String: Any] else { return .empty() }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    let removedCategory = try JSONDecoder().decode(PhotoCategory.self, from: jsonData)
                    return Observable.just(removedCategory)
                } catch {
                    return .error(error)
                }
            }
    }
    
    func categoryDidAdded() -> Observable<PhotoCategory> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.references.database.root.child("categories").observe(.childAdded, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else { return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                    let category = try JSONDecoder().decode(PhotoCategory.self, from: jsonData)
                    observer.onNext(category)
                } catch {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
}
