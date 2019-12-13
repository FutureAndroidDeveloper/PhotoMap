//
//  AddCategoryViewModelTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/13/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class AddCategoryViewModelTest: XCTestCase {
    var viewModel: AddCategoryViewModel!
    
    var validateService: ValidateService!
    var firebaseService: FirebaseDeleagate!
    var firebaseUpload: FirebaseUploading!
    var coreDataService: DataBase!
    
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        validateService = ValidateService()
        firebaseService = FirebaseService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        firebaseService = nil
        validateService = nil
        firebaseUpload = nil
        coreDataService = nil
    }

    
    // MARK: - isUniqueCategory Tests
    func testCorrectUploadNewCategory() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockUniqueCategoryAlwaysTrue()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let isLoading = scheduler.createObserver(Bool.self)
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        viewModel.isLoading
            .bind(to: isLoading)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, category)
            ])
            .bind(to: viewModel.addNewCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(isLoading.events, [
            .next(0, true),
            .next(0, false)
        ])
    }

    func testProblemWithSavingReturnError() {
        firebaseUpload = FBAddNewCategoryErrorMock()
        coreDataService = MockUniqueCategoryAlwaysTrue()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let expectedErrorMessage = "Mock Error"
        let errorMessage = scheduler.createObserver(String.self)
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        viewModel.showError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, category)
            ])
            .bind(to: viewModel.addNewCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    func testSaveDuplicateCategoryReturnError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let expectedErrorMessage = R.string.localizable.categoryAlreadyExists()
        let errorMessage = scheduler.createObserver(String.self)
        let category = PhotoCategory(hexColor: "test", engName: "test", ruName: "test")
        
        viewModel.showError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, category)
            ])
            .bind(to: viewModel.addNewCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    
    //MARK: - isValidHex Tests
    func testCorrectHexColorReturnColor() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let color = scheduler.createObserver(UIColor.self)
        let hexColor = "FFFF00"
        let expectedColor: UIColor = .yellow
        
        viewModel.newColor
            .bind(to: color)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, hexColor)
            ])
            .bind(to: viewModel.hexColor)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(color.events, [
            .next(0, expectedColor)
        ])
    }
    
    func testInvalidHexColorReturnError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String?.self)
        let hexColor = "WXYZ00"
        let expectedErrorMessage = R.string.localizable.invalidHexColor()
        
        viewModel.hexError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, hexColor)
            ])
            .bind(to: viewModel.hexColor)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    
    // MARK: - isEngCategoryValid Tests
    func testCorrectEngCategoryNameDissmissCategoryError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String?.self)
        let categoryName = "Normal Name"
        let expectedErrorMessage: String? = nil
        
        viewModel.engCategoryError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, categoryName)
            ])
            .bind(to: viewModel.engCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    func testInvalidEngCategoryNameReturnError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String?.self)
        let categoryName = "_W@*32Привет What(_+"
        let expectedErrorMessage = R.string.localizable.invalidName()
        
        viewModel.engCategoryError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, categoryName)
            ])
            .bind(to: viewModel.engCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    
    // MARK: - isRuCategoryValid Tests
    func testCorrectRuCategoryNameDissmissCategoryError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String?.self)
        let categoryName = "Валидное Название"
        let expectedErrorMessage: String? = nil
        
        viewModel.ruCategoryError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, categoryName)
            ])
            .bind(to: viewModel.ruCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    func testInvalidRuCategoryNameReturnError() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let errorMessage = scheduler.createObserver(String?.self)
        let categoryName = "_W@*32Привет What(_+"
        let expectedErrorMessage = R.string.localizable.invalidName()
        
        viewModel.ruCategoryError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, categoryName)
            ])
            .bind(to: viewModel.ruCategory)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(0, expectedErrorMessage)
        ])
    }
    
    
    // MARK: - engProvenText Tests
    func testEngCategoryEditingDidEndReturnFinalCategoryName() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let categoryName = scheduler.createObserver(String.self)
        let text = "  caTegorY Name   "
        let expectedName = "Category name"
        
        viewModel.engProvenText
            .bind(to: categoryName)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, text)
            ])
            .bind(to: viewModel.engCategoryEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(categoryName.events, [
            .next(0, expectedName)
        ])
    }
    
    
    // MARK: - ruProvenText Tests
    func testRuCategoryEditingDidEndReturnFinalCategoryName() {
        firebaseUpload = MockFBUpload()
        coreDataService = MockCoreData()
        viewModel = AddCategoryViewModel(validateService: validateService,
                                         firebaseService: firebaseService,
                                         firebaseUploadDelegate: firebaseUpload,
                                         coreDataService: coreDataService)
        
        let categoryName = scheduler.createObserver(String.self)
        let text = "  НазванИЕ КаТеГоРиИ   "
        let expectedName = "Название категории"
        
        viewModel.ruProvenText
            .bind(to: categoryName)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, text)
            ])
            .bind(to: viewModel.ruCategoryEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(categoryName.events, [
            .next(0, expectedName)
            ])
    }
}
