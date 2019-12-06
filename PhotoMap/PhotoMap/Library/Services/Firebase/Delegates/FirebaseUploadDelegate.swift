//
//  FirebaseUploadDelegate.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseStorage.FIRStorageMetadata
import FirebaseDatabase.FIRDatabaseReference
import CodableFirebase
import GeoFire

protocol FirebaseUploading {
    func upload(post: PostAnnotation) -> Completable
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata) -> Observable<URL>
    func addNewCategory(_ category: PhotoCategory) -> Completable
    func save(_ user: ApplicationUser) -> Completable
}

class FirebaseUploadDelegate: FirebaseUploading {
    private let bag = DisposeBag()
    private let references = FirebaseReferences.shared
    
    /// upload post model
    func upload(post: PostAnnotation) -> Completable {
        return uploadImage(post: post, metadata: references.defaultMetadata)
            .flatMap { [weak self] url -> Observable<DatabaseReference> in
                guard let self = self else { return .error(FirebaseError.badImage) }
                
                post.imageUrl = url.absoluteString
                let encoder = FirebaseEncoder()
                encoder.dataEncodingStrategy = .custom { _, _  in return }
                let data = try! encoder.encode(post)
                return self.references.database.childByAutoId().rx
                    .setValue(data).take(1)
            }
            .flatMap { [weak self] postReference -> Completable in
                guard let self = self else { return .error(FirebaseError.badImage) }
                return self.setGeoInfo(for: post, with: postReference)
            }
            .asCompletable()
    }
    
    /// upload image
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata) -> Observable<URL> {
        guard let imageData = post.image!.jpegData(compressionQuality: 0.75) else {
            return .error(FirebaseError.badImage)
        }
        
        let imageID = UUID().uuidString
        let imageRef = references.storage.child(post.category.lowercased()).child("\(imageID).jpg")
        return imageRef.rx.putData(imageData, metadata: metadata)
            .flatMapLatest { _ in imageRef.rx.downloadURL() }
            .take(1)
    }
    
    /// upload new category model
    func addNewCategory(_ category: PhotoCategory) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            do {
                let encoder = FirebaseEncoder()
                let data = try encoder.encode(category)
                self.references.database.root.child("categories").childByAutoId().setValue(data)
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    /// save new user account to data base
    func save(_ user: ApplicationUser) -> Completable {
        return Completable.create { completable in
            do {
                let encoder = FirebaseEncoder()
                let data = try encoder.encode(user)
                FirebaseReferences.shared.database.root
                    .child("users").child(user.id).setValue(data)
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    
    // MARK: - Private Methods
    
    /// set helpfull inforamtion for geo quary
    private func setGeoInfo(for post: PostAnnotation, with postReference: DatabaseReference) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            GeoFire(firebaseRef: self.references.database)
                .setLocation(CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude),
                             forKey: postReference.key!,
                             withCompletionBlock: { geoError in
                guard let error = geoError else {
                    completable(.completed)
                    return
                }
                completable(.error(error))
            })
            return Disposables.create()
        }
    }
}
