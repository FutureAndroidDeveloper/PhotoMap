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
    
    private let bag = DisposeBag()
    
    let willDisappear: AnyObserver<Void>
    let createTapped: AnyObserver<Void>
    let email: AnyObserver<String>
    let password: AnyObserver<String>
    let repeatPassword: AnyObserver<String>

    
    let disappear: Observable<Void>
    let create: Observable<Void>
    let error: Observable<String>
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        let _disappear = PublishSubject<Void>()
        willDisappear = _disappear.asObserver()
        disappear = _disappear.asObservable()
        
        let _create = PublishSubject<Void>()
        createTapped = _create.asObserver()
        
        let _email = PublishSubject<String>()
        email = _email.asObserver()
        
        let _password = PublishSubject<String>()
        password = _password.asObserver()
        
        let _repeatPassword = PublishSubject<String>()
        repeatPassword = _repeatPassword.asObserver()
        
        let _error = PublishSubject<String>()
        error = _error.asObservable()

        let accountData = Observable.combineLatest(_email.asObservable(), _password.asObservable()).share(replay: 1)
        
        // Create
        let signUpResult = _create.asObservable().withLatestFrom(accountData)
            .flatMap { (email, password) in
                firebaseService.createUser(withEmail: email, password: password)
            }
            .share(replay: 1)
        
        signUpResult
            .compactMap { $0 }
            .bind(to: _error)
            .disposed(by: bag)
        
        create = signUpResult
            .filter { $0 == nil }
            .take(1)
            .map { _ in Void() }
    }
}
