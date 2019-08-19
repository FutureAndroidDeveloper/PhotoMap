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
    
    let signUpTapped: AnyObserver<Void>
    let signInTapped: AnyObserver<Void>
    let name: AnyObserver<String>
    let password: AnyObserver<String>
    
    
    let signUp: Observable<Void>
    let signIn: Observable<Void>
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        
        // TODO: - Naming
        
        let _signUp = PublishSubject<Void>()
        signUpTapped = _signUp.asObserver()
        signUp = _signUp.asObservable()
        
        
        let _name = PublishSubject<String>()
        name = _name.asObserver()
        let a = _name.asObservable()
        
        let _singIn = PublishSubject<Void>()
        signInTapped = _singIn.asObserver()
        
        let _password = PublishSubject<String>()
        password = _password.asObserver()
        let b = _password.asObservable()
        
        let c = Observable.combineLatest(a, b).share(replay: 1)

        
        //sing In
        signIn = _singIn.asObservable().withLatestFrom(c)
            .do(onNext: { (mail, pass) in
                firebaseService.signIn(withEmail: mail, password: pass)
            })
            .map { _ in return Void() }
    }
}
