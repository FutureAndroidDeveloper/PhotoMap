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
import GeoFire

enum FirebaseError: Error {
    case badImage
    case badJson
}

extension FirebaseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badImage:
            return NSLocalizedString("Unkown Image", comment: "FirebaseError")
        case .badJson:
            return NSLocalizedString("Unkown JSON", comment: "FirebaseError")
        }
    }
}

class FirebaseService {
    private let bag = DisposeBag()
    let auth = Auth.auth()
    let databaseRef = Database.database().reference().child("model")
    let storage = Storage.storage().reference()
    
    static private let defaultMetadata: StorageMetadata = {
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        return uploadMetadata
    }()
    
    private let zoomDelta: Double = 1.0
    
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
        // upload post model
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }

            _ = self.uploadImage(post: post)
                .flatMap { url -> Observable<DatabaseReference> in
                    post.imageUrl = url.absoluteString
                    let encoder = FirebaseEncoder()
                    encoder.dataEncodingStrategy = .custom { _, _  in return }
                    let data = try! encoder.encode(post)
                    
                    return self.databaseRef.childByAutoId()
                        .rx.setValue(data).take(1)
                }
                .subscribe(onNext: { [weak self] postReference in
                    guard let self = self else {
                        completable(.completed)
                        return
                    }
                    // set helpfull inforamtion for geo quary
                    GeoFire(firebaseRef: self.databaseRef).setLocation(CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude), forKey: postReference.key!, withCompletionBlock: { geoError in
                        if let geoError = geoError {
                            completable(.error(geoError))
                        }
                        completable(.completed)
                    })
                }, onError: { error in
                    completable(.error(error))
                })
            
            return Disposables.create()
        }
    }
    
    func download(region: MKCoordinateRegion) -> Observable<[PostAnnotation]> {
        return Observable.create { [weak self] observer  in
            guard let self = self else { return Disposables.create() }
            if region.span.latitudeDelta > self.zoomDelta && region.span.longitudeDelta > self.zoomDelta {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            // Query location by region
            let regionQuery = GeoFire(firebaseRef: self.databaseRef).query(with: region)
            regionQuery.observe(.keyEntered, with: { [weak self] key, _ in
                guard let self = self else {
                    observer.onCompleted()
                    return
                }
                self.databaseRef.child(key).observe(.value, with: { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let post = try JSONDecoder().decode(PostAnnotation.self, from: jsonData)
                        observer.onNext([post])
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                        observer.onCompleted()
                    }
                })
            })
            return Disposables.create { regionQuery.removeAllObservers() }
        }
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata = defaultMetadata) -> Observable<URL> {
        // upload image
        guard let imageData = post.image!.jpegData(compressionQuality: 0.75) else {
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
