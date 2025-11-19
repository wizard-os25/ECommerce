//
//  MainCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

protocol MainCoordinatingControllerDependencies {
    func makeSideMenuViewController(actions: SideMenuMediatorActions) -> SideMenuViewController
    func makeProductsViewController(actions: ProductsMediatorActions) -> ProductsViewController
}


final class MainCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MainCoordinatingControllerDependencies
    
    private weak var mainViewController: MainViewController?
    private weak var productsVC: ProductsViewController?
    private weak var sideMenuVC: SideMenuViewController?

    init(
        navigationController: UINavigationController,
        dependencies: MainCoordinatingControllerDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Setup
    
    func setup(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        setupInitialContent()
        setupSideMenu()
    }
    
    // MARK: - Private
    
    private func setupInitialContent() {
        guard let mainViewController = mainViewController else { return }
        
        // Create ProductsViewController as initial content
        let actions = ProductsMediatorActions(
            showProductDetails: { [weak self] product in
                // Handle product details navigation if needed
            }
        )
        let productsVC = dependencies.makeProductsViewController(actions: actions)
        mainViewController.setContent(productsVC)
        self.productsVC = productsVC
    }
    
    private func setupSideMenu() {
        guard let mainViewController = mainViewController else { return }
        
        // Create SideMenuViewController
        let actions = SideMenuMediatorActions(
            showMenuItemType: { [weak self] item in
                self?.handleMenuItemSelection(item)
            }
        )
        let sideMenuVC = dependencies.makeSideMenuViewController(actions: actions)
        mainViewController.setSideMenu(sideMenuVC)
        self.sideMenuVC = sideMenuVC
    }
    
    // MARK: - Content Navigation
    
    func showContent(type: ContentType) {
        guard let mainViewController = mainViewController else { return }
        
        var newContentVC: UIViewController?
        
        switch type {
        case .home, .products:
            // Show ProductsViewController
            if productsVC == nil {
                let actions = ProductsMediatorActions(
                    showProductDetails: { [weak self] product in
                        // Handle product details navigation if needed
                    }
                )
                let productsVC = dependencies.makeProductsViewController(actions: actions)
                self.productsVC = productsVC
                newContentVC = productsVC
            } else if let productsVC = productsVC {
                newContentVC = productsVC
            }
        case .cart:
            // TODO: Implement cart view controller
            break
        case .profile:
            // TODO: Implement profile view controller
            break
        }
        
        // Set content and notify if needed
        if let contentVC = newContentVC {
            mainViewController.setContent(contentVC)
            // onContentChanged callback will be called by MainViewController if needed
        }
    }
    
    private func handleMenuItemSelection(_ item: SideMenuModel) {
        // Map SideMenuModel to ContentType and show content
        // This will be handled by MainMediatingController.didSelectMenuItem
    }
}


