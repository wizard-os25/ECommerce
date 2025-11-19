//
//  ProductsSceneDIContainer.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductsSceneDIContainer: ProductCoordinatingControllerDependencies {
    
    struct Dependencies {
        let productsDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    
    
    // MARK: - Repositories
    func makeProductsRepository() -> ProductsRepository {
        DefaultProductsRepository(
            dataTransferService: dependencies.productsDataTransferService
        )
    }
    
    // MARK: - Products List
    func makeProductsViewController(actions: ProductsMediatorActions) -> ProductsViewController {
        ProductsViewController.create(
            with: makeProductsMediatingController(actions: actions)
        )
    }
    
    func makeProductsMediatingController(actions: ProductsMediatorActions) -> ProductsMediatingController {
        DefaultProductsMediatingController(
            productsRepository: makeProductsRepository(),
            actions: actions
        )
    }
    
    // MARK: - Flow Coordinators
    func makeProductCoordinatingController(navigationController: UINavigationController) -> ProductCoordinatingController {
        ProductCoordinatingController(
            navigationController: navigationController,
            dependencies: self
        )
    }
}

