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
import RxCocoa

class FirebaseService {
    private let bag = DisposeBag()
    
    func createUser(email: String, password: String) {
        let auth = Auth.auth()
        
        // Create a password-based account
        auth.rx.createUser(withEmail: email, password: password)
            .subscribe(onNext: { result in
                print(result)
            }, onError: { error in
                print(error)
            })
            .disposed(by: bag)
    }
    
    func signIn(withEmail email: String, password: String) {
        let auth = Auth.auth()
        
        // Sign in a user with an email address and password
        auth.rx.signIn(withEmail: email, password: password)
            .subscribe(onNext: { result in
                print(result)
            }, onError: { error in
                print(error)
                print(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            print(error)
            return false
        }
    }
}
