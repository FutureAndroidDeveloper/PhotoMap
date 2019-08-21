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
import CodableFirebase
import FirebaseDatabase
import RxFirebaseDatabase

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
    let database = Database.database().reference()
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
    
    func upload(post: PostAnnotation) -> Completable {
        // upload info
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }

            _ = self.uploadImage(post: post)
                .flatMap { url -> Observable<DatabaseReference> in
                    post.imageUrl = url.absoluteString
                    let encoder = FirebaseEncoder()
                    encoder.dataEncodingStrategy = .custom { _, _  in return }
                    let data = try! encoder.encode(post)
                    
                    return self.database.child("model").childByAutoId()
                        .rx.setValue(data).take(1)
                }
                .subscribe(onNext: { _ in
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
            
            return Disposables.create()
        }
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata = defaultMetadata) -> Observable<URL> {
        // upload image
        guard let imageData = post.image.jpegData(compressionQuality: 0.75) else {
            return .error(FirebaseError.badImage)
        }
        
        let imageID = UUID().uuidString
        let imageRef = self.storage.child(post.category.lowercased()).child("\(imageID).jpg")
        return imageRef.rx.putData(imageData, metadata: metadata)
            .flatMapLatest { _ in imageRef.rx.downloadURL() }
            .take(1)
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
