//
//  MainCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

protocol MainCoordinatingControllerDependencies {
    func makeMainViewController() -> MainViewController
}

protocol MainCoordinatingControllerDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
    func didSetContentViewController(_ viewController: UIViewController)
}

final class MainCoordinatingController {
    
    private weak var delegate: MainCoordinatingControllerDelegate?
    private let dependencies: MainCoordinatingControllerDependencies
    private var sideMenuCoordinatingController: SideMenuCoordinatingController?
    
    init(
        dependencies: MainCoordinatingControllerDependencies,
        delegate: MainCoordinatingControllerDelegate? = nil
    ) {
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func makeMainViewController() -> MainViewController {
        let viewController = dependencies.makeMainViewController()
        // Set coordinating controller so MainViewController can create side menu
        viewController.setCoordinatingController(self)
        setupSideMenuCoordinatingController(for: viewController)
        return viewController
    }
    
    // MARK: - Public
    
    /// Setup side menu coordinating controller
    /// This is called automatically in makeMainViewController(), but can be called manually if needed
    func setupSideMenuCoordinatingController() {
        // Get side menu DI container from dependencies
        guard let mainSceneDIContainer = dependencies as? MainSceneDIContainer else { return }
        let sideMenuDIContainer = mainSceneDIContainer.makeSideMenuSceneDIContainer()
        
        // Create side menu coordinating controller
        sideMenuCoordinatingController = sideMenuDIContainer.makeSideMenuCoordinatingController(delegate: self)
    }
    
    func makeSideMenuViewController() -> SideMenuViewController? {
        return sideMenuCoordinatingController?.makeSideMenuViewController()
    }
    
    // MARK: - Private
    
    private func setupSideMenuCoordinatingController(for mainViewController: MainViewController) {
        setupSideMenuCoordinatingController()
    }
}

// MARK: - SideMenuCoordinatingControllerDelegate

extension MainCoordinatingController: SideMenuCoordinatingControllerDelegate {
    
    func didSelectMenuItem(at index: Int) {
        delegate?.didSelectMenuItem(at: index)
    }
}

