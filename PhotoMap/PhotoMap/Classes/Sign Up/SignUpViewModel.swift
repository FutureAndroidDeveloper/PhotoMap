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
    
    // MARK: - Input
    let willDisappear: AnyObserver<Void>
    let createTapped: AnyObserver<Void>
    let email: AnyObserver<String>
    let password: AnyObserver<String>
    let repeatPassword: AnyObserver<String>
    let emailEditingDidEnd: AnyObserver<String>
    let passwordEditingDidEnd: AnyObserver<String>
    let repeatPasswordEditingDidEnd: AnyObserver<String>
    let tappedShowPassword: AnyObserver<Void>

    // MARK: - Output
    let disappear: Observable<Void>
    let create: Observable<Void>
    let error: Observable<String>
    let emailError: Observable<String>
    let passwordError: Observable<String>
    let repeatPasswordError: Observable<String>
    let isPasswordHidden: Observable<Bool>
    
    init(firebaseService: FirebaseService = FirebaseService(),
         validateService: ValidateService = ValidateService(),
         isHidden: Bool = true) {
        
        let _tappedShowPassword = PublishSubject<Void>()
        tappedShowPassword = _tappedShowPassword.asObserver()
        
        isPasswordHidden = _tappedShowPassword
            .scan(isHidden) { value, _ in !value}
            .startWith(isHidden)
        
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
        
        let _emailError = PublishSubject<String>()
        emailError = _emailError.asObservable()
        
        let _emailEditingDidEnd = PublishSubject<String>()
        emailEditingDidEnd = _emailEditingDidEnd.asObserver()
        
        let _passwordError = PublishSubject<String>()
        passwordError = _passwordError.asObservable()
        
        let _passwordEditingDidEnd = PublishSubject<String>()
        passwordEditingDidEnd = _passwordEditingDidEnd.asObserver()
        
        let _repeatPasswordError = PublishSubject<String>()
        repeatPasswordError = _repeatPasswordError.asObservable()
        
        let _repeatPasswordEditingDidEnd = PublishSubject<String>()
        repeatPasswordEditingDidEnd = _repeatPasswordEditingDidEnd.asObserver()
        
        _emailEditingDidEnd
            .filter { email in
                return !validateService.isEmailValid(email)
                    && !email.isEmpty
            }
            .map { _ in R.string.localizable.invalidEmail() }
            .bind(to: _emailError)
            .disposed(by: bag)
        
        // NEW. Tests can fail with this block
        _emailEditingDidEnd
            .filter { email in
                return email.isEmpty
            }
            .map { _ in String() }
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
        
        _passwordEditingDidEnd
            .filter { password in
                return password.isEmpty
            }
            .map { _ in String() }
            .bind(to: _passwordError)
            .disposed(by: bag)
        
        _password
            .filter { password in
                return validateService.isPasswordValid(password)
            }
            .map { _ in String() }
            .bind(to: _passwordError)
            .disposed(by: bag)
        
        Observable.combineLatest(_repeatPasswordEditingDidEnd, _password)
            .filter { repeatPassword, password in
                return !validateService.isEmailValid(repeatPassword)
                    && !password.isEmpty && repeatPassword != password
            }
            .map { _ in R.string.localizable.notMatch() }
            .bind(to: _repeatPasswordError)
            .disposed(by: bag)
        
        _repeatPasswordEditingDidEnd
            .filter { $0.isEmpty}
            .map { _ in String() }
            .bind(to: _repeatPasswordError)
            .disposed(by: bag)
        
        Observable.combineLatest(_repeatPassword, _password)
            .filter { repeatPassword, password in
                return repeatPassword == password &&
                    validateService.isPasswordValid(password)
            }
            .map { _ in String() }
            .bind(to: _repeatPasswordError)
            .disposed(by: bag)

        let accountData = Observable.combineLatest(_email, _password, _repeatPassword).share(replay: 1)
        
        // Create
        let signUpResult = _create.asObservable().withLatestFrom(accountData)
            .filter { validateService.isAccaoutDataValid($0.0, $0.1, $0.2) }
            .flatMap { email, password, _ in
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
