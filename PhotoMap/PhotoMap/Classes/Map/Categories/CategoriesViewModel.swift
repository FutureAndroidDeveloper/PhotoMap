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
    
    // MARK: - Input
    let done: AnyObserver<Void>
    let addCategory: AnyObserver<Void>
    
    // MARK: - Output
    let categories: Observable<[String]>
    let didCancel: Observable<Void>
    let addCategoryTapped: Observable<Void>
    
    init(categoriesService: CategoriesService = CategoriesService()) {
        categories = categoriesService.getCategories()
        
        let _done = PublishSubject<Void>()
        done = _done.asObserver()
        didCancel = _done.asObservable()
        
        let _addCategory = PublishSubject<Void>()
        addCategory = _addCategory.asObserver()
        addCategoryTapped = _addCategory.asObservable()
    }
}
