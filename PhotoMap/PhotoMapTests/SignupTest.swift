//
//  SignupTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 9/9/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//


import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class SignupTest: XCTestCase {
    var viewModel: SignUpViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    override func setUp() {
        viewModel = SignUpViewModel()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    func testEnteredEmailChangesErrorMessage() {
        let errorMessage = scheduler.createObserver(String.self)
        var expectedErrorMessage = String()
        
        viewModel.emailError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                expectedErrorMessage = "Неправильная эл.почта"
            default:
                expectedErrorMessage = "Invalid email"
            }
        }
        
        scheduler.createColdObservable([
            .next(10, "invalidEmail"),
            .next(25, "validEmail@gmail.com")
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(15, "invalidEmail"),
            .next(20, ""),
            .next(30, "validEmail@gmail.com"),
            .next(40, "alsoInvalidEmail@a.")
            ])
            .bind(to: viewModel.emailEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(15, expectedErrorMessage),
            .next(20, ""),
            .next(25, ""),
            .next(40, expectedErrorMessage)
            ])
    }
    
    func testEnteredPasswordChangesErrorMessage() {
        let errorMessage = scheduler.createObserver(String.self)
        var expectedErrorMessage = String()
        
        viewModel.passwordError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                expectedErrorMessage = "Мин. 8 символов, 1 Буква и 1 Цифра"
            default:
                expectedErrorMessage = "Min. 8 characters, 1 Alphabet and 1 Number"
            }
        }
        
        scheduler.createColdObservable([
            .next(10, "invalidPassword"),
            .next(25, "validPass123")
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(15, "invalidPassword"),
            .next(20, ""),
            .next(30, "validPass1234"),
            .next(40, "alsoInvalidPass@a.")
            ])
            .bind(to: viewModel.passwordEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(15, expectedErrorMessage),
            .next(20, ""),
            .next(25, ""),
            .next(30, expectedErrorMessage),
            .next(40, expectedErrorMessage)
            ])
    }
    
    func testEmptyRepeatPasswordChangesErrorMessage() {
        let errorMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = String()
        
        viewModel.repeatPasswordError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([.next(10, "")])
            .bind(to: viewModel.repeatPasswordEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [.next(10, expectedErrorMessage)])
    }
    
    func testDifferentPasswordsChangesErrorMessage() {
        let errorMessage = scheduler.createObserver(String.self)
        var expectedErrorMessage = String()
        
        if let language = Locale.current.languageCode {
            switch language {
            case "ru":
                expectedErrorMessage = "Пароли не совпадают"
            default:
                expectedErrorMessage = "Passwords do not match"
            }
        }
        
        viewModel.repeatPasswordError
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([.next(10, "123456Qwerty")])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        scheduler.createColdObservable([.next(20, "Qwerty123456")])
            .bind(to: viewModel.repeatPasswordEditingDidEnd)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [.next(20, expectedErrorMessage)])
    }
    
    func testSignUpError() throws {
        let errorMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = R.string.localizable.duplicateEmail()
        
        viewModel.error
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(10, "admin@mail.com")
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(15, "123456qwerty"),
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(20, "123456qwerty"),
            ])
            .bind(to: viewModel.repeatPassword)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(30, ())
            ])
            .bind(to: viewModel.createTapped)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(try viewModel.error.toBlocking().first(), expectedErrorMessage)
    }
    
//    // DISABLED
//    func testCorrectSignUp() throws {
//        let errorMessage = scheduler.createObserver(String.self)
//        let expectedStatusCode = 200
//        
//        viewModel.error
//            .bind(to: errorMessage)
//            .disposed(by: bag)
//        
//        scheduler.createColdObservable([
//            .next(10, "newEmail2@gmail.com")                                     // every test i shoul set new email
//            ])
//            .bind(to: viewModel.email)
//            .disposed(by: bag)
//        
//        scheduler.createColdObservable([
//            .next(15, "12345qwerty"),
//            ])
//            .bind(to: viewModel.password)
//            .disposed(by: bag)
//        
//        scheduler.createColdObservable([
//            .next(20, "12345qwerty"),
//            ])
//            .bind(to: viewModel.repeatPassword)
//            .disposed(by: bag)
//        
//        scheduler.createColdObservable([
//            .next(30, ())
//            ])
//            .bind(to: viewModel.createTapped)
//            .disposed(by: bag)
//        
//        scheduler.start()
//        
//        XCTAssertEqual(try viewModel.create.map { 200 }.toBlocking().first(), expectedStatusCode)
//    }
    
    func testTappedPasswordIsHiddenChnagesPasswordSecureTextEntry() {
        let isHidden = scheduler.createObserver(Bool.self)
        
        viewModel.isPasswordHidden
            .bind(to: isHidden)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ()),
            .next(30, ())
            ])
            .bind(to: viewModel.tappedShowPassword)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(isHidden.events, [
            .next(0, true),
            .next(10, false),
            .next(20, true),
            .next(30, false)
            ])
    }
}

