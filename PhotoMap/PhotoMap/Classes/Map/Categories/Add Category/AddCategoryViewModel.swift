//
//  AddCategoryViewModel.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/12/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class AddCategoryViewModel {
    
    private let bag = DisposeBag()
    
    // MARK: - Input
    let hexColor: AnyObserver<String?>
    let engCategory: AnyObserver<String?>
    let ruCategory: AnyObserver<String?>
    let engCategoryEditingDidEnd: AnyObserver<String?>
    let ruCategoryEditingDidEnd: AnyObserver<String?>
    let addNewCategory: AnyObserver<PhotoCategory?>
    
    // MARK: - Output
    let newColor: Observable<UIColor>
    let hexError: Observable<String?>
    let engCategoryError: Observable<String?>
    let ruCategoryError: Observable<String?>
    let engProvenText: Observable<String>
    let ruProvenText: Observable<String>
    let isLoading: Observable<Bool>
    let showError: Observable<String>
    
    init(validateService: ValidateService = ValidateService(),
         firebaseService: FirebaseDeleagate = FirebaseService(),
         firebaseUploadDelegate: FirebaseUploading = FirebaseUploadDelegate(),
         coreDataService: CoreDataService = CoreDataService(appDelegate:
        UIApplication.shared.delegate as! AppDelegate)) {
        
        firebaseService.setUploadDelegate(firebaseUploadDelegate)
        
        let _engCategory = PublishSubject<String?>()
        engCategory = _engCategory.asObserver()
        
        let _ruCategory = PublishSubject<String?>()
        ruCategory = _ruCategory.asObserver()
        
        let _engCategoryError = PublishSubject<String?>()
        engCategoryError = _engCategoryError.asObservable()
        
        let _ruCategoryError = PublishSubject<String?>()
        ruCategoryError = _ruCategoryError.asObservable()
        
        let _engCategoryEditingDidEnd = PublishSubject<String?>()
        engCategoryEditingDidEnd = _engCategoryEditingDidEnd.asObserver()
        
        let _ruCategoryEditingDidEnd = PublishSubject<String?>()
        ruCategoryEditingDidEnd = _ruCategoryEditingDidEnd.asObserver()
        
        let _addNewCategory = PublishSubject<PhotoCategory?>()
        addNewCategory = _addNewCategory.asObserver()
        
        let _isLoading = PublishSubject<Bool>()
        isLoading = _isLoading.asObservable()
        
        let _showError = PublishSubject<String>()
        showError = _showError.asObservable()
        
        let _hex = PublishSubject<String?>()
        hexColor = _hex.asObserver()
        
        let isUniqueCategory =  _addNewCategory
            .compactMap { $0 }
            .do(onNext: { _ in
                _isLoading.onNext(true)
            })
            .map { coreDataService.isUnique(category: $0) }
            .share(replay: 1, scope: .whileConnected)
        
        isUniqueCategory
            .filter { $0 }
            .withLatestFrom(_addNewCategory)
            .compactMap { $0 }
            .flatMap { firebaseService.addNewCategory($0) }
            .subscribe(onNext: { _ in
                _isLoading.onNext(false)
            }, onError: { error in
                _showError.onNext(error.localizedDescription)
                _isLoading.onNext(false)
            })
            .disposed(by: bag)
        
        isUniqueCategory
            .filter { !$0 }
            .do(onNext: { _ in
                _isLoading.onNext(false)
            })
            .map { _ in R.string.localizable.categoryAlreadyExists() }
            .bind(to: _showError)
            .disposed(by: bag)

        let isValidHex = _hex
            .compactMap { $0 }
            .map { "#\($0)" }
            .flatMap { Observable.combineLatest(Observable.just($0),
                                                Observable.just(validateService.isHexColor($0))) }
            .share(replay: 1, scope: .whileConnected)
        
        newColor = isValidHex
            .filter { $0.1 }
            .compactMap { UIColor(hex: $0.0) }
        
        hexError = isValidHex
            .filter { !$0.1 }
            .map { _ in "Error" }
   
        let isEngCategoryValid = _engCategory
            .compactMap { $0 }
            .map { validateService.isEnglish(text: $0) }
            .share(replay: 1, scope: .whileConnected)
        
        isEngCategoryValid
            .filter { $0 }
            .map { _ in nil }
            .bind(to: _engCategoryError)
            .disposed(by: bag)
        
        isEngCategoryValid
            .filter { !$0 }
            .map { _ in "Error" }
            .bind(to: _engCategoryError)
            .disposed(by: bag)
        
        let isRuCategoryValid = _ruCategory
            .compactMap { $0 }
            .map { validateService.isRussian(text: $0) }
            .share(replay: 1, scope: .whileConnected)
        
        isRuCategoryValid
            .filter { $0 }
            .map { _ in nil }
            .bind(to: _ruCategoryError)
            .disposed(by: bag)
        
        isRuCategoryValid
            .filter { !$0 }
            .map { _ in "Error" }
            .bind(to: _ruCategoryError)
            .disposed(by: bag)
        
        engProvenText = _engCategoryEditingDidEnd
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { category in
                var newCategory = category
                return newCategory.capitalizeFirstLetter()
            }
        
        ruProvenText = _ruCategoryEditingDidEnd
            .compactMap { $0 }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { category in
                var newCategory = category
                return newCategory.capitalizeFirstLetter()
            }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
            a = 1
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        return nil
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() -> String {
        return self.capitalizingFirstLetter()
    }
}
