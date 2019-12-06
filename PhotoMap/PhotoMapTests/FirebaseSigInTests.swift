//
//  CoreDataDelegatesTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/6/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class FirebaseSigInTests: XCTestCase {
    var validateService: ValidateService!
    var firebaseService: FirebaseDeleagate!
    var firebaseAuthDelegate: FirebaseAuthentication!
    var viewModel: AuthenticationViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    override func setUp() {
        validateService = ValidateService()
        firebaseService = FirebaseService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        validateService = nil
        firebaseService = nil
        scheduler = nil
    }

    func testSignInTapWithCorrectCreditsIsSuccess() {
        let email = "TestEmail@gmail.com"
        let password = "12345678Qwerty"
        
        firebaseAuthDelegate = MockSuccessFirebaseAuthDelegate()
        viewModel = AuthenticationViewModel(firebaseService: firebaseService,
                                            firebaseAuthDelegate: firebaseAuthDelegate,
                                            validateService: validateService, isHidden: true)
        
        let successSignIn = scheduler.createObserver(Void.self)
        let expectedStatusCode = 200
        
        viewModel.signIn
            .bind(to: successSignIn)
            .disposed(by: bag)
        
        // send Email
        scheduler.createColdObservable([
            .next(10, email)
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)
        
        // send Password
        scheduler.createColdObservable([
            .next(15, password)
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)
        
        // send tap to Sign In Button
        scheduler.createColdObservable([
            .next(20, Void())
            ])
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)
        
        scheduler.start()
        
        XCTAssertEqual(try viewModel.signIn.map { 200 }.toBlocking().first(), expectedStatusCode)
    }
    
    func testSignInTapWithBadCreditsIsShowError() {
        let email = "TestEmail@gmail.com"
        let password = "12345678Qwerty"
        
        firebaseAuthDelegate = MockErrorFirebaseAuthDelegate()
        viewModel = AuthenticationViewModel(firebaseService: firebaseService,
                                            firebaseAuthDelegate: firebaseAuthDelegate,
                                            validateService: validateService, isHidden: true)
        
        let errorMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = R.string.localizable.signInError()
        
        viewModel.error
            .bind(to: errorMessage)
            .disposed(by: bag)

        // send Email
        scheduler.createColdObservable([
            .next(10, email)
            ])
            .bind(to: viewModel.email)
            .disposed(by: bag)

        // send Password
        scheduler.createColdObservable([
            .next(15, password)
            ])
            .bind(to: viewModel.password)
            .disposed(by: bag)

        // send tap to `Sign In` Button
        scheduler.createColdObservable([
            .next(20, Void())
            ])
            .bind(to: viewModel.signInTapped)
            .disposed(by: bag)

        scheduler.start()
        
        XCTAssertEqual(errorMessage.events, [
            .next(20, expectedErrorMessage),
            .completed(20)
        ])
    }
}


class MockSuccessFirebaseAuthDelegate: FirebaseAuthentication {
    func createUser(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return .empty()
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return .just(ApplicationUser(id: email, email: password))
    }
    
    func signOut() -> Completable {
        return .empty()
    }
}


class MockErrorFirebaseAuthDelegate: FirebaseAuthentication {
    func createUser(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return .empty()
    }
    
    func signIn(withEmail email: String, password: String) -> Observable<ApplicationUser> {
        return .error(FirebaseError.badJson)
    }
    
    func signOut() -> Completable {
        return .empty()
    }
}
