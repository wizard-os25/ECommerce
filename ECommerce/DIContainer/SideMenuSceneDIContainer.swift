//
//  SideMenuSceneDIContainer.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

final class SideMenuSceneDIContainer: SideMenuCoordinatingControllerDependencies {
    
    // Shared instance to ensure same controller is used
    private lazy var sharedController: SideMenuController = {
        DefaultSideMenuController()
    }()
    
    // MARK: - Side Menu
    
    func makeSideMenuViewController() -> SideMenuViewController {
        SideMenuViewController.create(
            with: makeSideMenuController()
        )
    }
    
    func makeSideMenuController() -> SideMenuController {
        // Return shared instance so coordinating controller can observe it
        return sharedController
    }
    
    // MARK: - Flow Coordinators
    
    func makeSideMenuCoordinatingController(
        delegate: SideMenuCoordinatingControllerDelegate? = nil
    ) -> SideMenuCoordinatingController {
        SideMenuCoordinatingController(
            dependencies: self,
            delegate: delegate
        )
    }
}

