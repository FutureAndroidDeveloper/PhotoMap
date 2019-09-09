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
    let emailEditingDidEnd: AnyObserver<String>
    let passwordEditingDidEnd: AnyObserver<String>
    let tappedShowPassword: AnyObserver<Void>
    
    // MARK: - Output
    let signUp: Observable<Void>
    let signIn: Observable<Void>
    let error: Observable<String>
    let emailError: Observable<String>
    let passwordError: Observable<String>
    let isPasswordHidden: Observable<Bool>
    
    init(firebaseService: FirebaseService = FirebaseService(),
         validateService: ValidateService = ValidateService(),
         isHidden: Bool = true) {
        
        let _tappedShowPassword = PublishSubject<Void>()
        tappedShowPassword = _tappedShowPassword.asObserver()
        
        isPasswordHidden = _tappedShowPassword
            .scan(isHidden) { value, _ in !value}
            .startWith(isHidden)
        
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
        
        let _emailError = PublishSubject<String>()
        emailError = _emailError.asObservable()
        
        let _emailEditingDidEnd = PublishSubject<String>()
        emailEditingDidEnd = _emailEditingDidEnd.asObserver()
        
        let _passwordError = PublishSubject<String>()
        passwordError = _passwordError.asObservable()
        
        let _passwordEditingDidEnd = PublishSubject<String>()
        passwordEditingDidEnd = _passwordEditingDidEnd.asObserver()
        
        _emailEditingDidEnd
            .filter { email in
                return !validateService.isEmailValid(email)
                    && !email.isEmpty
            }
            .map { _ in R.string.localizable.invalidEmail() }
            .bind(to: _emailError)
            .disposed(by: bag)
        
        _email
            .filter { email in
                return validateService.isEmailValid(email)
            }
            .map { _ in String() }
            .bind(to: _emailError)
            .disposed(by: bag)
        
        _passwordEditingDidEnd
            .filter { password in
                return !validateService.isEmailValid(password)
                    && !password.isEmpty
            }
            .map { _ in R.string.localizable.invalidPassword() }
            .bind(to: _passwordError)
            .disposed(by: bag)
        
        _password
            .filter { password in
                return validateService.isPasswordValid(password)
            }
            .map { _ in String() }
            .bind(to: _passwordError)
            .disposed(by: bag)
        
        let accountData = Observable.combineLatest(_email, _password).share(replay: 1)

        //sing In
        let signInResult = _singIn.asObservable().withLatestFrom(accountData)
            .filter { validateService.isAccaoutDataValid($0.0, $0.1) }
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
