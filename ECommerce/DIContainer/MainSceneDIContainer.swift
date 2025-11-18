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
        let mediatingController = DefaultMainMediatingController(delegate: self)
        return mediatingController
    }
    
    // MARK: - Side Menu
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        return dependencies.sideMenuSceneDIContainer
    }
    
    // MARK: - Flow Coordinators
    
    func makeMainCoordinatingController(
        delegate: MainCoordinatingControllerDelegate? = nil
    ) -> MainCoordinatingController {
        MainCoordinatingController(
            dependencies: self,
            delegate: delegate
        )
    }
}

// MARK: - MainMediatingControllerDelegate

extension MainSceneDIContainer: MainMediatingControllerDelegate {
    
    func didSelectMenuItem(at index: Int) {
        // Handle menu item selection
        // This can be forwarded to a higher level coordinator if needed
    }
}

