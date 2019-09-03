//
//  FullPhotoViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class FullPhotoViewModel {
    private let disposebag = DisposeBag()
    
    // MARK: - Input
    let backTapped: AnyObserver<Void>
    let postDidLoad: AnyObserver<PostAnnotation>
    
    // MARK: - Output
    let back: Observable<Void>
    let post: Observable<PostAnnotation>
    let longDate: Observable<String?>
    
    init(dateService: DateService = DateService()) {
        let _back = PublishSubject<Void>()
        backTapped = _back.asObserver()
        back = _back.asObservable()
        
        let _post = ReplaySubject<PostAnnotation>.create(bufferSize: 1)
        postDidLoad = _post.asObserver()
        post = _post.asObservable()
        
        longDate = post
            .map { dateService.getLongDate(timestamp: $0.date, modifier: .at) }
    }
}
