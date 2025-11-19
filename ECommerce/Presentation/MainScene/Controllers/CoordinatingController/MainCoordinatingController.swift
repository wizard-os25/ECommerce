//
//  MainCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

protocol MainCoordinatingControllerDependencies {
    
}


final class MainCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MainCoordinatingControllerDependencies
    
    private weak var productsVC: ProductsViewController?
    private weak var sideMenuVC: SideMenuViewController?

    init(
        navigationController: UINavigationController,
        dependencies: MainCoordinatingControllerDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Private
    
    func setupInitialContent(for mainViewController: MainViewController) {
        
        // Create ProductsViewController as initial content
        
        // Set as content of MainViewController
    }
}


