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
import FirebaseStorage
import RxFirebaseStorage
import RxSwift

enum FirebaseError: Error {
    case badImage
}

extension FirebaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badImage:
            return NSLocalizedString("Unkown Image", comment: "FirebaseError")
        }
    }
}

class FirebaseService {
    private let bag = DisposeBag()
    let auth = Auth.auth()
    let storage = Storage.storage().reference()
    
    static private let defaultMetadata: StorageMetadata = {
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        return uploadMetadata
    }()
    
    
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
    
    func upload(post: PostAnnotation, metadata: StorageMetadata = defaultMetadata) -> Completable {
        // upload only image NOW
        return Completable.create { completable in
            guard let imageData = post.image.jpegData(compressionQuality: 0.75) else {
                completable(.error(FirebaseError.badImage))
                return Disposables.create()
            }
            
            let imageID = UUID().uuidString
            let imageRef = self.storage.child(post.category.lowercased()).child("\(imageID).jpg")
            _ = imageRef.rx.putData(imageData, metadata: metadata)
                .flatMapLatest { _ in imageRef.rx.downloadURL() }
                .subscribe(onNext: { (url) in
                    completable(.completed)
                }, onError: { (error) in
                    completable(.error(error))
                })
            
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
