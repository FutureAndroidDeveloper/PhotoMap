//
//  AuthenticationTest.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 9/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class AuthenticationTest: XCTestCase {
    var viewModel: AuthenticationViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    override func setUp() {
        let firebaseService = FirebaseService()
        viewModel = AuthenticationViewModel(firebaseService: firebaseService)
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
            .next(25, ""),
            .next(30, expectedErrorMessage),
            .next(40, expectedErrorMessage)
            ])
    }
    
    func testSignInError() throws {
        let errorMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = "The password is invalid or the user does not have a password."
        
        viewModel.error
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(10, "aa@mail.com")                                      // replace to NORMAL EMAIL
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(15, "incorrectAccountPassword123"),
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(20, ())
            ])
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(try viewModel.error.toBlocking().first(), expectedErrorMessage)
    }
    
    func testCorrectSignIn() throws {
        let errorMessage = scheduler.createObserver(String.self)
        let expectedStatusCode = 200
        
        viewModel.error
            .bind(to: errorMessage)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(10, "aa@mail.com")                                      // replace to NORMAL EMAIL
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(15, "12345qwerty"),
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(20, ())
            ])
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(try viewModel.signIn.map { 200 }.toBlocking().first(), expectedStatusCode)
    }
    
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
