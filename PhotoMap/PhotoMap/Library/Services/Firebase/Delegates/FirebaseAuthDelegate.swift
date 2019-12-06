//
//  FirebaseAuthDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

protocol FirebaseAuthentication {
    func createUser(withEmail email: String, password: String) -> Observable<ApplicationUser>
    func signIn(withEmail email: String, password: String) -> Observable<ApplicationUser>
    func signOut() -> Completable
}

class FirebaseAuthDelegate: FirebaseAuthentication {
    private let bag = DisposeBag()
    private let references = FirebaseReferences.shared
    
    func createUser(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return references.auth.rx
            .createUser(withEmail: email, password: password)
            .map { $0.user }
            .map { ApplicationUser(id: $0.uid, email: $0.email!) }
            .take(1)
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return references.auth.rx
            .signIn(withEmail: email, password: password)
            .map { $0.user }
            .map { ApplicationUser(id: $0.uid, email: $0.email!) }
            .take(1)
    }
    
    func signOut() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            do {
                try self.references.auth.signOut()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
}
