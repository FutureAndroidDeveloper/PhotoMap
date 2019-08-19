//
//  SignUpViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class SignUpViewModel {
    let willDisappear: AnyObserver<Void>
    
    let disappear: Observable<Void>
    
    init() {
        let _disappear = PublishSubject<Void>()
        willDisappear = _disappear.asObserver()
        disappear = _disappear.asObservable()
    }
}
