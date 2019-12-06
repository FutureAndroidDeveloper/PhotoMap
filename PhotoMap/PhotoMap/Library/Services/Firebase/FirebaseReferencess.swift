//
//  FirebaseReferencess.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 12/4/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FirebaseReferences {
    let auth = Auth.auth()
    let database = Database.database().reference().child("model")
    let storage = Storage.storage().reference()
    let zoomDelta: Double = 1.0
    
    let defaultMetadata: StorageMetadata = {
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        return uploadMetadata
    }()
    
    static let shared = FirebaseReferences()
    private init() {}
}
