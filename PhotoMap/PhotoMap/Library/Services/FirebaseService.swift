//
//  FirebaseService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/14/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxFirebaseAuthentication
import FirebaseAuth
import RxSwift

class FirebaseService {
    private let bag = DisposeBag()
    let auth = Auth.auth()
    
    func createUser(withEmail email: String, password: String) -> Observable<String?> {
        return Observable.create { [weak self] observer in
            // Create a password-based account
            self?.auth.rx.createUser(withEmail: email, password: password)
                .subscribe(onNext: { _ in
                    observer.onNext(nil)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onNext(error.localizedDescription)
                    observer.onCompleted()
                })
                .disposed(by: self!.bag)
            return Disposables.create()
        }
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<String?> {
        return Observable.create { [weak self] observer in
            // Sign in a user with an email address and password
            self?.auth.rx.signIn(withEmail: email, password: password)
                .subscribe(onNext: { _ in
                    observer.onNext(nil)
                    observer.onCompleted()
                }, onError: { error in
                    observer.onNext(error.localizedDescription)
                    observer.onCompleted()
                })
                .disposed(by: self!.bag)
            return Disposables.create()
        }
    }
    
    
    func signOut() -> Bool {
        do {
            try auth.signOut()
            return true
        } catch {
            print(error)
            return false
        }
    }
}
