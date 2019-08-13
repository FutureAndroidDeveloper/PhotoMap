//
//  PostViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class PostViewModel {
    
    // TODO: - Make a description.
    
    // MARK: - Input
    let didSelectedImage: AnyObserver<UIImage>
    let cancel: AnyObserver<Void>
    let done: AnyObserver<PostAnnotation>
    let dismiss: AnyObserver<Void>
    let creationDate: AnyObserver<Date>
    
    // MARK: - Output
    let postImage: Observable<UIImage>
    let date: Observable<String>
    let didCancel: Observable<Void>
    let post: Observable<PostAnnotation>
    let shouldDismass: Observable<Void>
    let categories: Observable<[String]>
    
    let timestamp: Observable<Int>
    
    init(dateService: DateService = DateService(), categoriesService: CategoriesService = CategoriesService()) {
        let _didSelectedImage = ReplaySubject<UIImage>.create(bufferSize: 1)
        didSelectedImage = _didSelectedImage.asObserver()
        postImage = _didSelectedImage.asObservable()
        
        let _cancel = PublishSubject<Void>()
        cancel = _cancel.asObserver()
        didCancel = _cancel.asObservable()
        
        let _done = PublishSubject<PostAnnotation>()
        done = _done.asObserver()
        post = _done.asObservable()
        
        let _dismiss = PublishSubject<Void>()
        dismiss = _dismiss.asObserver()
        shouldDismass = _dismiss.asObservable()
        
        let _creationDate = ReplaySubject<Date>.create(bufferSize: 1)
        creationDate = _creationDate.asObserver()
        date = _creationDate.asObservable()
            .map { dateService.getLongDate(timestamp: Int($0.timeIntervalSince1970), modifier: .dash) }
        
        timestamp = _creationDate.asObservable()
            .map { Int($0.timeIntervalSince1970) }
        
        categories = categoriesService.getCategories()
    }
}
