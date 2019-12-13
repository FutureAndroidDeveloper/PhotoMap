//
//  CategoriesViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/28/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class CategoriesViewModel {
    let bag = DisposeBag()
    
    // MARK: - Input
    let done: AnyObserver<Void>
    let addCategory: AnyObserver<Void>
    let searchText: AnyObserver<String>
    let removeCategory: AnyObserver<String>
    
    // MARK: - Output
    let categories: Observable<[PhotoCategory]>
    let didCancel: Observable<Void>
    let addCategoryTapped: Observable<Void>
    let filteredCategories: Observable<[PhotoCategory]>
    
    init(firebaseService: FirebaseDeleagate = FirebaseService(),
         firebaseNotificationDelegate: FirebaseNotification = FirebaseNotificationDelegate(),
         firebaseRemoveDelegate: FirebaseRemovable = FirebaseRemoveDelegate(),
         coreDataService: DataBase = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate)) {
        
        firebaseService.setNotificationDelegate(firebaseNotificationDelegate)
        firebaseService.setRemoveDelegate(firebaseRemoveDelegate)
        
        let _categories = ReplaySubject<[PhotoCategory]>.create(bufferSize: 1)
        categories = _categories.asObservable()
        
        let _done = PublishSubject<Void>()
        done = _done.asObserver()
        didCancel = _done.asObservable()
        
        let _addCategory = PublishSubject<Void>()
        addCategory = _addCategory.asObserver()
        addCategoryTapped = _addCategory.asObservable()
        
        let _searchText = PublishSubject<String>()
        searchText = _searchText.asObserver()
        
        let _filteredCategories = PublishSubject<[PhotoCategory]>()
        filteredCategories = _filteredCategories.asObservable()
        
        let _removeCategory = PublishSubject<String>()
        removeCategory = _removeCategory.asObserver()
        
        let search = Observable.combineLatest(_searchText, _categories)
            .share(replay: 1, scope: .whileConnected)
            
        search
            .filter { !$0.0.isEmpty }
            .map { searchText, allCategories -> [PhotoCategory] in
                allCategories.filter { category in
                    category.engName.lowercased().contains(searchText.lowercased()) ||
                        category.ruName.lowercased().contains(searchText.lowercased())
                }
            }
            .bind(to: _filteredCategories)
            .disposed(by: bag)
        
        search
            .filter { $0.0.isEmpty }
            .map { $0.1 }
            .bind(to: _filteredCategories)
            .disposed(by: bag)
        
        var fetchedCategories = [PhotoCategory]()
        
        firebaseService.categoryDidAdded()
            .do(onNext: { fetchedCategories.append($0) })
            .map { [weak self] _ -> [PhotoCategory] in
                guard let self = self else { return [] }
                return self.sortCategoriesWithLocale(fetchedCategories)
            }
            .bind(to: _categories)
            .disposed(by: bag)
        
        _removeCategory
            .map { categoryName -> PhotoCategory? in
                if let language = Locale.current.languageCode {
                    switch language {
                    case "ru":
                        return fetchedCategories.first() { $0.ruName.uppercased() == categoryName }
                    default:
                        return fetchedCategories.first() { $0.engName.uppercased() == categoryName }
                    }
                }
                return nil
            }
            .compactMap { $0 }
            .flatMap { firebaseService.removeCategory($0)}
            .subscribe()
            .disposed(by: bag)
        
        firebaseService.categoryDidRemoved()
            .flatMap { coreDataService.removeCategoryFromCoredata($0) }
            .compactMap { $0 }
            .do(onNext: { removedCategory in
                for category in fetchedCategories {
                    if category == removedCategory {
                        let index = fetchedCategories.firstIndex(of: category)!
                        fetchedCategories.remove(at: index)
                        break
                    }
                }
            })
            .map { [weak self] _ -> [PhotoCategory] in
                guard let self = self else { return [] }
                return self.sortCategoriesWithLocale(fetchedCategories)
            }
            .bind(to: _categories)
            .disposed(by: bag)
    }
    
    private func sortCategoriesWithLocale(_ categories: [PhotoCategory]) -> [PhotoCategory] {
        var sortedCategories = categories
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru": sortedCategories.sort { $0.ruName < $1.ruName }
            default: sortedCategories.sort { $0.engName < $1.engName }
            }
        }
        return sortedCategories
    }
}
