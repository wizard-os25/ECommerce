//
//  ProductDetailCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import UIKit

final class ProductDetailCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: ProductDetailCoordinatingControllerDependencies
    
    init(
        navigationController: UINavigationController,
        dependencies: ProductDetailCoordinatingControllerDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start(productItem: ProductItemModel) {
        print("🔵 [ProductDetailCoordinatingController] start called")
        print("   📦 Product: \(productItem.name) (ID: \(productItem.id))")
        print("   🔧 Creating ProductDetailViewController...")
        
        let viewController = dependencies.makeProductDetailViewController(productItem: productItem)
        print("   ✅ ProductDetailViewController created: \(type(of: viewController))")
        
        guard let navController = navigationController else {
            print("   ⚠️ navigationController is nil, cannot push view controller")
            return
        }
        
        print("   🚀 Pushing view controller to navigation stack...")
        print("   📊 Navigation stack before push: \(navController.viewControllers.count) view controllers")
        navController.pushViewController(viewController, animated: true)
        print("   ✅ pushViewController called with animated: true")
        print("   📊 Navigation stack after push: \(navController.viewControllers.count) view controllers")
    }
}
