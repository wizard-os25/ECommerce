//
//  SideMenuSceneDIContainer.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

final class SideMenuSceneDIContainer: SideMenuCoordinatingControllerDependencies {
    
    
    struct Dependencies {
        
    }
    
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Side Menu
    
    func makeSideMenuViewController(actions: SideMenuMediatorActions) -> SideMenuViewController {
        SideMenuViewController.create(
            with: makeSideMenuMediatingController(actions: actions)
        )
    }
    
    func makeSideMenuMediatingController(actions: SideMenuMediatorActions) -> SideMenuMediatingController {
        DefaultSideMenuMediatingController(
            actions: actions
        )
    }
    
    func makeSideMenuItemViewController(for item: SideMenuModel) -> UIViewController {
//        DefaultSideMenuItemsMediatingController(
//            item: item
//        )
        return UIViewController()
    }
    
    // MARK: - Flow Coordinators
    
    func makeSideMenuCoordinatingController(navigationController: UINavigationController) -> SideMenuCoordinatingController {
        SideMenuCoordinatingController(
            navigationController: navigationController,
            dependencies: self
        )
    }
}

