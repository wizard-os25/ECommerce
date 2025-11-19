//
//  MainSceneDIContainer.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

final class MainSceneDIContainer: MainCoordinatingControllerDependencies {
    
    struct Dependencies {
        let sideMenuSceneDIContainer: SideMenuSceneDIContainer
        let productsSceneDIContainer: ProductsSceneDIContainer
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Main View Controller
    
    func makeMainViewController() -> MainViewController {
        // Create coordinator first
        let coordinator = makeMainCoordinatingController(navigationController: UINavigationController())
        
        // Create MainMediatorActions with coordinator's showContent method
        let actions = MainMediatorActions(
            showContent: { [weak coordinator] contentType in
                coordinator?.showContent(type: contentType)
            },
            onContentChanged: { viewController in
                // Can be used for analytics or tracking
                // Example: Analytics.trackContentChanged(viewController)
            },
            onSideMenuRevealed: {
                // Can be used for analytics or tracking
                // Example: Analytics.trackSideMenuRevealed()
            },
            onSideMenuHidden: {
                // Can be used for analytics or tracking
                // Example: Analytics.trackSideMenuHidden()
            }
        )
        
        // Create mediating controller with actions
        let mediatingController = makeMainMediatingController(actions: actions)
        
        // Create MainViewController
        let mainViewController = MainViewController.create(with: mediatingController)
        
        // Setup coordinator with MainViewController
        mainViewController.setupCoordinator(coordinator)
        
        return mainViewController
    }
    
    func makeMainMediatingController(actions: MainMediatorActions? = nil) -> MainMediatingController {
        return DefaultMainMediatingController(actions: actions)
    }
    
    // MARK: - Side Menu
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        return dependencies.sideMenuSceneDIContainer
    }
    
    func makeSideMenuViewController(actions: SideMenuMediatorActions) -> SideMenuViewController {
        dependencies.sideMenuSceneDIContainer.makeSideMenuViewController(actions: actions)
    }
    
    // MARK: - Products
    
    func makeProductsSceneDIContainer() -> ProductsSceneDIContainer {
        return dependencies.productsSceneDIContainer
    }
    
    func makeProductsViewController(actions: ProductsMediatorActions) -> ProductsViewController {
        dependencies.productsSceneDIContainer.makeProductsViewController(actions: actions)
    }
    
    // MARK: - Flow Coordinators
    
    func makeMainCoordinatingController(
        navigationController: UINavigationController
    ) -> MainCoordinatingController {
        MainCoordinatingController(
            navigationController: navigationController,
            dependencies: self
        )
    }
}



