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
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Main View Controller
    
    func makeMainViewController() -> MainViewController {
        MainViewController.create(with: makeMainMediatingController())
    }
    
    func makeMainMediatingController() -> MainMediatingController {
         DefaultMainMediatingController()
    }
    
    // MARK: - Side Menu
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        return dependencies.sideMenuSceneDIContainer
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



