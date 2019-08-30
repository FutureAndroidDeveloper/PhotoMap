//
//  TimelineViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/29/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class TimelineViewModel {
    
    // MARK: - Input
    let showCategories: AnyObserver<Void>
    let downloadUserPost: AnyObserver<Void>
    
    // MARK: - Output
    let categoriesTapped: Observable<Void>
    let posts: Observable<[PostAnnotation]>
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        let _categories = PublishSubject<Void>()
        showCategories = _categories.asObserver()
        categoriesTapped = _categories.asObservable()
        
        let _posts = PublishSubject<[PostAnnotation]>()
        posts = _posts.asObservable()
        
        let _shouldDownload = PublishSubject<Void>()
        downloadUserPost = _shouldDownload.asObserver()
        
        _ = _shouldDownload
            .flatMap { firebaseService.downloadUserPosts().distinctUntilChanged() }
            .bind(to: _posts)
    }
}
