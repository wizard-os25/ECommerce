//
//  SideMenuSceneDIContainer.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

final class SideMenuSceneDIContainer: SideMenuCoordinatingControllerDependencies {
    
    // Shared instance to ensure same mediating controller is used
    private lazy var sharedMediatingController: SideMenuMediatingController = {
        DefaultSideMenuMediatingController()
    }()
    
    // MARK: - Side Menu
    
    func makeSideMenuViewController() -> SideMenuViewController {
        SideMenuViewController.create(
            with: makeSideMenuMediatingController()
        )
    }
    
    func makeSideMenuMediatingController() -> SideMenuMediatingController {
        // Return shared instance so coordinating controller can observe it
        return sharedMediatingController
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

