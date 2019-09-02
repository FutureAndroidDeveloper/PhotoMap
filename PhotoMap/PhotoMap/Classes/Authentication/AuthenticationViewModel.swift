//
//  AuthenticationViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/14/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class AuthenticationViewModel {
    private let bag = DisposeBag()
    
    // MARK: - Input
    let signUpTapped: AnyObserver<Void>
    let signInTapped: AnyObserver<Void>
    let email: AnyObserver<String>
    let password: AnyObserver<String>
    
    // MARK: - Output
    let signUp: Observable<Void>
    let signIn: Observable<Void>
    let error: Observable<String>
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        let _error = PublishSubject<String>()
        error = _error.asObservable()
        
        let _signUp = PublishSubject<Void>()
        signUpTapped = _signUp.asObserver()
        signUp = _signUp.asObservable()
        
        let _email = PublishSubject<String>()
        email = _email.asObserver()
        
        let _singIn = PublishSubject<Void>()
        signInTapped = _singIn.asObserver()
        
        let _password = PublishSubject<String>()
        password = _password.asObserver()
        
        let accountData = Observable.combineLatest(_email, _password).share(replay: 1)

        //sing In
        let signInResult = _singIn.asObservable().withLatestFrom(accountData)
            .flatMap { (email, password) in
                firebaseService.signIn(withEmail: email, password: password)
            }
            .share(replay: 1)
        
        signInResult
            .compactMap { $0 }
            .bind(to: _error)
            .disposed(by: bag)
        
        signIn = signInResult
            .take(1)
            .filter { $0 == nil }
            .map { _ in Void() }
    }
}
