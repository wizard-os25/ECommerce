//
//  SideMenuCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

protocol SideMenuCoordinatingControllerDependencies {
    func makeSideMenuViewController() -> SideMenuViewController
}

protocol SideMenuCoordinatingControllerDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
}

final class SideMenuCoordinatingController {
    
    private weak var delegate: SideMenuCoordinatingControllerDelegate?
    private let dependencies: SideMenuCoordinatingControllerDependencies
    private var mediatingController: SideMenuMediatingController?
    
    init(
        dependencies: SideMenuCoordinatingControllerDependencies,
        delegate: SideMenuCoordinatingControllerDelegate? = nil
    ) {
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func makeSideMenuViewController() -> SideMenuViewController {
        let viewController = dependencies.makeSideMenuViewController()
        // Get mediating controller from DI container to observe menu selections
        if let diContainer = dependencies as? SideMenuSceneDIContainer {
            let controller = diContainer.makeSideMenuMediatingController()
            self.mediatingController = controller
            bindToMediatingController(controller)
        }
        return viewController
    }
    
    // MARK: - Private
    
    private func bindToMediatingController(_ controller: SideMenuMediatingController) {
        // Observe selectedIndex changes and forward to delegate
        controller.selectedIndex.observe(on: self) { [weak self] index in
            self?.delegate?.didSelectMenuItem(at: index)
        }
    }
}
