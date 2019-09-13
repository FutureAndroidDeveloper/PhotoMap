//
//  AddCategoryViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class AddCategoryViewModel {
    
    // MARK: - Input
    let goBack: AnyObserver<Void>
    
    // MARK: - Output
    let backTapped: Observable<Void>
    
    init() {
        let _back = PublishSubject<Void>()
        goBack = _back.asObserver()
        backTapped = _back.asObservable()
    }
}
