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
    
    private var mediatingController: ProductsMediatingController!
    private var productsTableViewController: ProductsTableViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with mediatingController: ProductsMediatingController
    ) -> ProductsViewController {
        let view = ProductsViewController.instantiateViewController()
        view.mediatingController = mediatingController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: mediatingController)
        setupChildViewController()
        // viewDidLoad will be called on mediatingController by ProductsTableViewController
    }
    
    private func setupViews() {
        title = mediatingController.screenTitle
        emptyDataLabel.text = mediatingController.emptyDataTitle
    }
    
    private func setupChildViewController() {
        let tableViewController = ProductsTableViewController.instantiateViewController()
        tableViewController.mediatingController = mediatingController
        
        add(tableViewController, to: productsListContainer)
        productsTableViewController = tableViewController
    }
    
    private func bind(to mediatingController: ProductsMediatingController) {
        mediatingController.items.observe(on: self) { [weak self] _ in
            self?.updateItems()
        }
        mediatingController.loading.observe(on: self) { [weak self] loading in
            self?.updateLoading(loading)
        }
        mediatingController.error.observe(on: self) { [weak self] error in
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
            LoadingView.show()
        } else {
            LoadingView.hide()
            productsListContainer.isHidden = mediatingController.isEmpty
            emptyDataLabel.isHidden = !mediatingController.isEmpty
        }
        
        productsTableViewController?.updateLoading(loading)
    }
    
    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: mediatingController.errorTitle, message: error)
    }
}
