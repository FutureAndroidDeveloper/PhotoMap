//
//  FBCategoryDidRemovedMockCategory.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

@testable import PhotoMap

class FBCategoryDidRemovedMockCategory: MockFBNotification {
    var category: PhotoCategory!
    var categories: [PhotoCategory]!
    
    var emmitRemovedCategorySignal: PublishSubject<Void>!
    
    init(categories: [PhotoCategory], removedCategory: PhotoCategory) {
        self.categories = categories
        self.category = removedCategory
        self.emmitRemovedCategorySignal = PublishSubject<Void>()
    }
    
    override func categoryDidRemoved() -> Observable<PhotoCategory> {
        return emmitRemovedCategorySignal.asObservable()
            .flatMap { [weak self] _ -> Observable<PhotoCategory> in
                guard let self = self else { return .empty() }
                return Observable.just(self.category)
            }
    }
    
    override func categoryDidAdded() -> Observable<PhotoCategory> {
        return Observable<PhotoCategory>.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            self.categories.forEach { observer.onNext($0) }
            return Disposables.create()
        }
    }
}
