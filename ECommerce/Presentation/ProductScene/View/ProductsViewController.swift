//
//  ProductsViewController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductsViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    @IBOutlet private var productsListContainer: UIView!
    @IBOutlet private var emptyDataLabel: UILabel!
    
    private var productsController: ProductsController!
    private var productsTableViewController: ProductsTableViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with productsController: ProductsController
    ) -> ProductsViewController {
        let view = ProductsViewController.instantiateViewController()
        view.productsController = productsController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: productsController)
        setupChildViewController()
        setupSidebarGesture()
        // viewDidLoad will be called on mediatingController by ProductsTableViewController
    }
    
    // MARK: - Sidebar Integration
    
    /// Setup sidebar reveal gesture using SidebarRevealBehavior
    private func setupSidebarGesture() {
        // Use SidebarRevealBehavior with custom action to find parent MainViewController and reveal sidebar
        addSidebarRevealBehavior { [weak self] in
            // Find parent MainViewController and reveal sidebar
            if let mainVC: MainViewController = self?.findParentViewController() {
                mainVC.revealSidebar()
            }
        }
    }
    
    private func setupViews() {
        title = productsController.screenTitle
        emptyDataLabel.text = productsController.emptyDataTitle
    }
    
    private func setupChildViewController() {
        let tableViewController = ProductsTableViewController.instantiateViewController()
        tableViewController.productsController = productsController
        
        add(tableViewController, to: productsListContainer)
        productsTableViewController = tableViewController
    }
    
    private func bind(to productsController: ProductsController) {
        productsController.items.observe(on: self) { [weak self] _ in
            self?.updateItems()
        }
        productsController.loading.observe(on: self) { [weak self] loading in
            self?.updateLoading(loading)
        }
        productsController.error.observe(on: self) { [weak self] error in
            self?.showError(error)
        }
    }
    
    private func updateItems() {
        productsTableViewController?.reload()
    }
    
    private func updateLoading(_ loading: Bool) {
        emptyDataLabel.isHidden = true
        productsListContainer.isHidden = true
        
        if loading {
            EcoLoadingView.show()
        } else {
            EcoLoadingView.hide()
            productsListContainer.isHidden = productsController.isEmpty
            emptyDataLabel.isHidden = !productsController.isEmpty
        }
        
        productsTableViewController?.updateLoading(loading)
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: productsController.errorTitle, message: error)
    }
}
