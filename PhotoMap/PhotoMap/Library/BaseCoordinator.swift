//
//  BaseCoordinator.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxSwift

class BaseCoordinator<ResultType> {
    
    typealias CoordinatorResult = ResultType
    
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    
    // Unique identifier of coordinator
    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()
    
    // MARK: - Methods
    
    /// Stores coordinator to the `childCoordinators` dictionary.
    /// - Parameter coordinator: Child coordinator to store.
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }
    
    /// Release coordinator from the `childCoordinators` dictionary.
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    /// 1.
    private func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        
        return coordinator.start()
            .do(onNext: { [weak self] _ in
                self?.free(coordinator: coordinator)
            })
    }
    
    /// Starts job of the coordinator.
    /// - Returns: Result of coordinator job.
    func start() -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }
}
