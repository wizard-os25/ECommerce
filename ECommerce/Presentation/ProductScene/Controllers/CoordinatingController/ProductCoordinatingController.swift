//
//  ProductCoordinatingController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

protocol ProductCoordinatingControllerDependencies {
    func makeProductsDetailsViewController(for product: ProductItemModel) -> ProductsViewController
    //func makeProductsDetailsViewController(product: Product) -> UIViewController
//    func makeProductsQueriesSuggestionsListViewController(
//        didSelect: @escaping ProductsQueryListViewModelDidSelectAction
//    ) -> UIViewController
}

final class ProductCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: ProductCoordinatingControllerDependencies
    
//    private weak var productsQueriesSuggestionsVC: UIViewController?
    
    init(navigationController: UINavigationController,
         dependencies: ProductCoordinatingControllerDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    private func showProductDetails(product: ProductItemModel) {
        let vc = dependencies.makeProductsDetailsViewController(for: product)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
