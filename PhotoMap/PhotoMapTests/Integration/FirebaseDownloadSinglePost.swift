//
//  FirebaseDownloadSinglePost.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
@testable import PhotoMap

enum SinglePostEror: Error {
    case noPostsWithUserID(id: String)
}

extension SinglePostEror: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noPostsWithUserID(let id):
            return "There are no posts with '\(id)' user ID"
        }
    }
}

class FirebaseDownloadSinglePost {
    func getPost(userId: String) -> Single<PostAnnotation> {
        return Single<PostAnnotation>.create { single in
            // Query posts created by user ID
            let userPostsQuery = FirebaseReferences.shared.database
                .queryOrdered(byChild: "userID")
                .queryEqual(toValue: userId)
            
            userPostsQuery.observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [AnyHashable: [String: Any]] else { return }
                let jsonPosts = value.map { $1 }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonPosts, options: [])
                    let posts = try JSONDecoder().decode([PostAnnotation].self, from: jsonData)
                    
                    guard let post = posts.first else {
                        single(.error(SinglePostEror.noPostsWithUserID(id: userId)))
                        return
                    }
                    single(.success(post))
                } catch {
                    single(.error(error))
                }
            })
            return Disposables.create { userPostsQuery.removeAllObservers() }
        }
    }
}
