//
//  FirebaseAuthTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/10/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

import Firebase
import FirebaseAuth
import RxFirebaseAuthentication

@testable import PhotoMap

class FirebaseAuthTests: XCTestCase {
    var firebaseAuth: FirebaseAuthentication!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    override func setUp() {
        firebaseAuth = FirebaseAuthDelegate()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
//        firebaseAuth = nil
    }

    
    // MARK: - createUser Tests
    func testCreateNewUserWithCorrectUserDataReturnApplicationUser() {
        let email = "newtestuser@gmail.com"
        let password = "12345678Qwerty"
        let expectedResult = ApplicationUser(id: "RandomId", email: email)
        
        
        XCTAssertEqual(try firebaseAuth.createUser(withEmail: email, password: password).toBlocking().first()!, expectedResult)
        
        // ПОСЛЕ КАЖДОГО ЭТОГО ТЕСТА НУЖНО УДАЛЯТЬ ЗАПИСЬ В FB
    }
   
    func testCreateNewUserThatAlreadyExistsReturnError() {
        // exsisting user's email
        let email = "admin@mail.com"
        let password = "12345678Qwerty"
        let expectedError = "The email address is already in use by another account."
        var firebaseError = ""      // recived error from firebase
        
        XCTAssertEqual(try firebaseAuth.createUser(withEmail: email, password: password)
            .catchError { error -> Observable<ApplicationUser> in
                firebaseError = error.localizedDescription  // save revied error message
                return .just(.init(id: "", email: ""))      // return empty user account
            }
            .map { _ in firebaseError }
            .toBlocking()
            .first(), expectedError)
    }
    
    
    // MARK: - signIn Tests
    func testSignInWithCorrectUserDataReturnApplicationUser() {
        let email = "admin@mail.com"
        let password = "1029384756gexa"
        let expectedResult = ApplicationUser(id: "", email: email)
        
        
        XCTAssertEqual(try firebaseAuth.signIn(withEmail: email, password: password).toBlocking().first()!, expectedResult)
    }
    
    func testSignInWithIncorrectUserDataReturnErrorqw() {
        let email = "randomEmail@gmail.com"
        let password = "12345678Qwerty"
        let expectedError = "There is no user record corresponding to this identifier. The user may have been deleted."
        var firebaseError = ""      // recived error from firebase
        
        XCTAssertEqual(try firebaseAuth.signIn(withEmail: email, password: password)
            .catchError{ error -> Observable<ApplicationUser> in
                firebaseError = error.localizedDescription  // save revied error message
                return .just(.init(id: "", email: ""))      // return empty user account
            }
            .map { _ in firebaseError }
            .toBlocking()
            .first(), expectedError)
    }
    
    
    // MARK: - signOut Tests
    func testSignOutWorkCorrect() {
        let signOutCompleted = scheduler.createObserver(Never.self)
        
        firebaseAuth.signOut()
            .asObservable()
            .bind(to: signOutCompleted)
            .disposed(by: bag)
        
        XCTAssertEqual(signOutCompleted.events, [.completed(0)])
    }
}
