//
//  SideMenuCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

protocol SideMenuCoordinatingControllerDependencies {
    func makeSideMenuViewController() -> SideMenuViewController
    func makeSideMenuController() -> SideMenuController
}

final class SideMenuCoordinatingController {
    
    private let dependencies: SideMenuCoordinatingControllerDependencies
    private var sideMenuController: SideMenuController?
    
    init(
        dependencies: SideMenuCoordinatingControllerDependencies
    ) {
        self.dependencies = dependencies
        setupController()
    }
    
    // MARK: - Public
    
    func makeSideMenuViewController() -> SideMenuViewController {
        let controller = dependencies.makeSideMenuController()
        let viewController = SideMenuViewController.create(with: controller)
        return viewController
    }
    
    // MARK: - Private
    
    private func setupController() {
        let controller = dependencies.makeSideMenuController()
        self.sideMenuController = controller
        bindToController(controller)
    }
    
    private func bindToController(_ controller: SideMenuController) {
        // Observe menu item selection
//        controller.selectedIndex.observe(on: self) { [weak self] index in
//        }
    }
}
