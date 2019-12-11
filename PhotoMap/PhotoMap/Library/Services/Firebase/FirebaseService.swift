//
//  FirebaseService.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/14/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import MapKit.MKGeometry
import FirebaseStorage.FIRStorageMetadata

typealias FirebaseCore = FirebaseAuthentication & FirebaseDownloading
    & FirebaseUploading & FirebaseNotification & FirebaseRemovable

protocol TestProtocol {
    func setAuthDelegate(_ deleagte: FirebaseAuthentication)
    func setDownloadDelegate(_ deleagte: FirebaseDownloading)
    func setUploadDelegate(_ deleagte: FirebaseUploading)
    func setNotificationDelegate(_ deleagte: FirebaseNotification)
    func setRemoveDelegate(_ deleagte: FirebaseRemovable)
}

typealias FirebaseDeleagate = FirebaseCore & TestProtocol

class FirebaseService: FirebaseCore, TestProtocol {
    func setAuthDelegate(_ deleagte: FirebaseAuthentication) {
        firebaseAuth = deleagte
    }
    
    func setDownloadDelegate(_ deleagte: FirebaseDownloading) {
        firebaseDownload = deleagte
    }
    
    func setUploadDelegate(_ deleagte: FirebaseUploading) {
        firebaseUpload = deleagte
    }
    
    func setNotificationDelegate(_ deleagte: FirebaseNotification) {
        firebaseNotification = deleagte
    }
    
    func setRemoveDelegate(_ deleagte: FirebaseRemovable) {
        firebaseRemove = deleagte
    }
    
    
    var firebaseAuth: FirebaseAuthentication!
    var firebaseDownload: FirebaseDownloading!
    var firebaseUpload: FirebaseUploading!
    var firebaseNotification: FirebaseNotification!
    var firebaseRemove: FirebaseRemovable!
    
    func createUser(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return firebaseAuth!.createUser(withEmail: email, password: password)
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return firebaseAuth.signIn(withEmail: email, password: password)
    }
    
    func signOut() -> Completable {
        return firebaseAuth.signOut()
    }
    
    func downloadUserPosts() -> Observable<[PostAnnotation]> {
        return firebaseDownload.downloadUserPosts()
    }
    
    func download(in region: MKCoordinateRegion, uncheckedCategories categories: [String]) -> Observable<[PostAnnotation]> {
        return firebaseDownload.download(in: region, uncheckedCategories: categories)
    }
    
    func getCategories() -> Observable<[PhotoCategory]> {
        return firebaseDownload.getCategories()
    }
    
    func upload(post: PostAnnotation) -> Completable {
        return firebaseUpload.upload(post: post)
    }
    
    func uploadImage(post: PostAnnotation, metadata: StorageMetadata) -> Observable<URL> {
        return firebaseUpload.uploadImage(post: post, metadata: FirebaseReferences.shared.defaultMetadata)
    }
    
    func addNewCategory(_ category: PhotoCategory) -> Completable {
        return firebaseUpload.addNewCategory(category)
    }
    
    func save(_ user: ApplicationUser) -> Completable {
        return firebaseUpload.save(user)
    }
    
    func postDidRemoved() -> Observable<PostAnnotation> {
        return firebaseNotification.postDidRemoved()
    }
    
    func categoryDidRemoved() -> Observable<PhotoCategory> {
        return firebaseNotification.categoryDidRemoved()
    }
    
    func categoryDidAdded() -> Observable<PhotoCategory> {
        return firebaseNotification.categoryDidAdded()
    }
    
    func removeIncorrectPost(_ post: PostAnnotation) -> Observable<PostAnnotation> {
        return firebaseRemove.removeIncorrectPost(post)
    }
    
    func removeCategory(_ category: PhotoCategory) -> Observable<PhotoCategory> {
        return firebaseRemove.removeCategory(category)
    }
    
    func removeOldPost(posts: [PostAnnotation]) -> Observable<[PostAnnotation]> {
        return firebaseRemove.removeOldPost(posts: posts)
    }
    
}
