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
    
    private weak var navigationController: UINavigationController?
    private weak var delegate: MainCoordinatingControllerDelegate?
    private let dependencies: MainCoordinatingControllerDependencies
    private var sideMenuCoordinatingController: SideMenuCoordinatingController?
    private var appDIContainer: AppDIContainer?
    
    init(
        navigationController: UINavigationController,
        dependencies: MainCoordinatingControllerDependencies,
        delegate: MainCoordinatingControllerDelegate? = nil
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        self.delegate = delegate
    }
    
    func start() {
        let viewController = dependencies.makeMainViewController()
        
        // Set coordinating controller so MainViewController can create side menu
        viewController.setCoordinatingController(self)
        
        // Set dependencies if available
        if let mainSceneDIContainer = dependencies as? MainSceneDIContainer,
           let appDIContainer = getAppDIContainer(from: mainSceneDIContainer) {
            viewController.setDependencies(appDIContainer: appDIContainer)
            self.appDIContainer = appDIContainer
        }
        
        // Setup side menu coordinating controller
        setupSideMenuCoordinatingController()
        
        // Setup callback to set initial content after view appears
        viewController.onViewDidAppear = { [weak self] in
            self?.setupInitialContent(for: viewController)
        }
        
        // Set MainViewController as root
        navigationController?.setViewControllers([viewController], animated: false)
    }
    
    // MARK: - Public
    
    func makeMainViewController() -> MainViewController {
        let viewController = dependencies.makeMainViewController()
        viewController.setCoordinatingController(self)
        
        if let mainSceneDIContainer = dependencies as? MainSceneDIContainer,
           let appDIContainer = getAppDIContainer(from: mainSceneDIContainer) {
            viewController.setDependencies(appDIContainer: appDIContainer)
        }
        
        setupSideMenuCoordinatingController()
        return viewController
    }
    
    /// Setup side menu coordinating controller
    /// This is called automatically in start() and makeMainViewController()
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
    
    func getSideMenuController() -> SideMenuController? {
        guard let mainSceneDIContainer = dependencies as? MainSceneDIContainer else { return nil }
        let sideMenuDIContainer = mainSceneDIContainer.makeSideMenuSceneDIContainer()
        return sideMenuDIContainer.makeSideMenuController()
    }
    
    // MARK: - Private
    
    private func getAppDIContainer(from mainSceneDIContainer: MainSceneDIContainer) -> AppDIContainer? {
        return mainSceneDIContainer.getAppDIContainer()
    }
    
    private func setupInitialContent(for mainViewController: MainViewController) {
        guard let appDIContainer = appDIContainer else { return }
        
        // Create ProductsViewController as initial content
        let productsSceneDIContainer = appDIContainer.makeProductsSceneDIContainer()
        let productsViewController = productsSceneDIContainer.makeProductsViewController()
        
        // Set as content of MainViewController
        mainViewController.setContentViewController(productsViewController)
    }
}

// MARK: - SideMenuCoordinatingControllerDelegate

extension MainCoordinatingController: SideMenuCoordinatingControllerDelegate {
    
    func didSelectMenuItem(at index: Int) {
        delegate?.didSelectMenuItem(at: index)
    }
}

