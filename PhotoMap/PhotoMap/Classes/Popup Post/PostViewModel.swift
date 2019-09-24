//
//  PostViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/5/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel {
    let bag = DisposeBag()
    
    // MARK: - Input
    let didSelectedImage: AnyObserver<UIImage>
    let cancel: AnyObserver<Void>
    let done: AnyObserver<PostAnnotation>
    let creationDate: AnyObserver<Date>
    let fullPhotoTapped: AnyObserver<PostAnnotation>
    let searchText: AnyObserver<String?>
    let editablePost: AnyObserver<PostAnnotation?>
    
    // MARK: - Output
    let postImage: Observable<UIImage>
    let date: Observable<String>
    let didCancel: Observable<Void>
    let post: Observable<PostAnnotation>
    let categories: Observable<[Category]>
    let showFullPhoto: Observable<PostAnnotation>
    let timestamp: Observable<Int>
    let filteredCategories: Observable<[Category]>
    let editablePostSelected: Observable<PostAnnotation>
    let editableCategory: Observable<Category>
    
    init(dateService: DateService = DateService(),
         coreDataService: CoreDataService = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate),
         firebaseService: FirebaseService = FirebaseService()) {
        
        let _didSelectedImage = ReplaySubject<UIImage>.create(bufferSize: 1)
        didSelectedImage = _didSelectedImage.asObserver()
        postImage = _didSelectedImage.asObservable()
        
        let _editablePost = ReplaySubject<PostAnnotation?>.create(bufferSize: 1)
        editablePost = _editablePost.asObserver()
        editablePostSelected = _editablePost.asObservable().compactMap { $0 }
        
//        let _editableCategory = PublishSubject<Category>()
//        editableCategory = _editableCategory.asObservable()
        
        let _cancel = PublishSubject<Void>()
        cancel = _cancel.asObserver()
        didCancel = _cancel.asObservable()
        
        let _done = PublishSubject<PostAnnotation>()
        done = _done.asObserver()
        post = _done.asObservable()
        
        let _fullPhoto = PublishSubject<PostAnnotation>()
        fullPhotoTapped = _fullPhoto.asObserver()
        showFullPhoto = _fullPhoto.asObservable()

        let _categories = ReplaySubject<[Category]>.create(bufferSize: 1)
        categories = _categories.asObservable()
        
        let _searchText = PublishSubject<String?>()
        searchText = _searchText.asObserver()
        
        let _filteredCategories = PublishSubject<[Category]>()
        filteredCategories = _filteredCategories.asObservable()

        let _creationDate = ReplaySubject<Date>.create(bufferSize: 1)
        creationDate = _creationDate.asObserver()
        date = _creationDate.asObservable()
            .map { dateService.getLongDate(timestamp: Int($0.timeIntervalSince1970), modifier: .dash) }
        
        timestamp = _creationDate.asObservable()
            .map { Int($0.timeIntervalSince1970) }
        
//        firebaseService.getCategories()
//            .bind(to: _categories)
//            .disposed(by: bag)
        
        var allCategories = [Category]()
        
        coreDataService.fetch()
            .map { $0.sorted(by: <) }
            .do(onNext: { allCategories = $0 })
            .bind(to: _categories)
            .disposed(by: bag)
        
        
        editableCategory = editablePostSelected
            .compactMap { post in
                allCategories.first(where: { (category) -> Bool in
                    category.hexColor == post.hexColor
                })
            }.take(1)
        
//            .map { $0.sorted(by: <) }
//            .do(onNext: { allCategories = $0 })
//            .bind(to: _categories)
//            .disposed(by: bag)
        
        _searchText
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .map { searchText in
                allCategories.filter { $0.description.uppercased().contains(searchText.uppercased()) }
            }
            .bind(to: _filteredCategories)
            .disposed(by: bag)
        
        _searchText
            .compactMap { $0 }
            .filter { $0.isEmpty }
            .map { _ in allCategories }
            .bind(to: _filteredCategories)
            .disposed(by: bag)
    }
}
