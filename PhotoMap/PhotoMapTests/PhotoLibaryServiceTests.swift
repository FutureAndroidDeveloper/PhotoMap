//
//  PhotoLibaryServiceTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/2/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

@testable import PhotoMap

class PhotoLibaryServiceTests: XCTestCase {
    var photoLibraryService: Authorizing!
    var viewModel: MapViewModel!
    var scheduler: TestScheduler!
    var bag = DisposeBag()
    
    let locationService = LocationService()
    let dateService = DateService()
    let firebaseService = FirebaseService()
    let coreDataService = CoreDataService(appDelegate: UIApplication.shared.delegate as! AppDelegate)

    override func setUp() {
        photoLibraryService = PhotoLibraryService()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        photoLibraryService = nil
    }

    func testExample() {
        photoLibraryService = UnauthorizedPhotoLibraryService()
        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
                                 locationService: locationService,
                                 dateService: dateService,
                                 firebaseService: firebaseService,
                                 coreDataService: coreDataService)
        
        let permissionMessage = scheduler.createObserver(String.self)
        let expectedErrorMessage = "Разрешите доступ к Фотографиям"
        
        viewModel.showPermissionMessage
            .bind(to: permissionMessage)
            .disposed(by: bag)

        scheduler.createColdObservable([
            .next(10, Void())
            ])
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)
        
        scheduler.start()

        XCTAssertEqual(permissionMessage.events, [
            .next(10, expectedErrorMessage)
        ])
    }
    
    
    func testExampleHeh() {
        photoLibraryService = AuthorizedPhotoLibraryService()
        viewModel = MapViewModel(photoLibraryService: photoLibraryService,
                                 locationService: locationService,
                                 dateService: dateService,
                                 firebaseService: firebaseService,
                                 coreDataService: coreDataService)
        
        let isImageSheetShown = scheduler.createObserver(Bool.self)
        let expectedResult = true
        
        viewModel.showImageSheet
            .map { true }
            .bind(to: isImageSheetShown)
            .disposed(by: bag)

        scheduler.createColdObservable([
            .next(10, Void())
            ])
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(isImageSheetShown.events, [
            .next(10, expectedResult)
            ])
    }
}


class UnauthorizedPhotoLibraryService: Authorizing {
    var authorized: Observable<Bool> {
        return Observable.just(false)
    }
}

class AuthorizedPhotoLibraryService: Authorizing {
    var authorized: Observable<Bool> {
        return Observable.just(true)
    }
}
