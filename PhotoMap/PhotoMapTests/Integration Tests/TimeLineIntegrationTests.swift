//
//  TimeLineIntegrationTests.swift
//  PhotoMapTests
//
//  Created by Kiryl Klimiankou on 12/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import RxBlocking

import CoreLocation.CLLocation

@testable import PhotoMap

class TimeLineIntegrationTests: XCTestCase {
    var viewModel: TimelineViewModel!
    var scheduler: TestScheduler!
    var bag: DisposeBag!

    override func setUp() {
        viewModel = TimelineViewModel()
        scheduler = TestScheduler(initialClock: 0)
        bag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
    }

    func testLoadedPostsTransformToSections() {
        let adminEmail = "admin@mail.com"
        let adminPassword = "1029384756gexa"
        FirebaseAuthDelegate()
            .signIn(withEmail: adminEmail, password: adminPassword)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.scheduler.start()
            })
            .disposed(by: bag)
        
        let expectedResult = ["Август 2012", "Октябрь 2009"]
        let sectionHeaders = scheduler.createObserver([String].self)
        let expectation = XCTestExpectation(description: "")
        
        viewModel.sections
            .map { $0.map { $0.header } }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: sectionHeaders)
            .disposed(by: bag)
        
        scheduler.createColdObservable([
            .next(0, Void())
            ])
            .bind(to: viewModel.downloadUserPost)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(sectionHeaders.events, [
            .next(0, expectedResult)
        ])
    }
    
    func testBuildSectionsForPostsReturnArrayOfSections() {
        let posts = buildTestPosts(count: 6)
        
        let expectation = XCTestExpectation(description: "build sections")
        let buildSections = scheduler.createObserver([String].self)
        let expectedResult = ["Март 1970", "Февраль 1970", "Январь 1970"]
        
        viewModel.buildSections(posts: posts)
            .map { $0.map { $0.header } }
            .do(onNext: { _ in expectation.fulfill() })
            .bind(to: buildSections)
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 20)
        XCTAssertEqual(buildSections.events, [
            .next(0, expectedResult),
            .completed(0)
        ])
    }
    
    // в одном месяце ~2.6 млн секунд.
    // создаю посты с шагом в 1 млн секунд. В месяц попадает [1; 3] поста.
    private func buildTestPosts(count: Int) -> [PostAnnotation] {
        var result = [PostAnnotation]()
        
        (0..<count).forEach { counter in
            let doubleCounter = Double(counter)
            let location = CLLocationCoordinate2D(latitude: doubleCounter,
                                                  longitude: doubleCounter)
            let post = PostAnnotation(date: (counter + 1) * 1_000_000, hexColor: "1",
                                      category: "1", postDescription: "1",
                                      imageUrl: nil, userId: "1",
                                      coordinate: location)
            result.append(post)
        }
        return result
    }
}
