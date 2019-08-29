//
//  CategoriesViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/28/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class CategoriesViewModel {
    
    let done: AnyObserver<Void>
    
    let categories: Observable<[String]>
    let didCancel: Observable<Void>
    
    init(categoriesService: CategoriesService = CategoriesService()) {
        categories = categoriesService.getCategories()
        
        let _done = PublishSubject<Void>()
        done = _done.asObserver()
        didCancel = _done.asObservable()
    }
}
