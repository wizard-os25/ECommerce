//
//  ProductsTableViewController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductsTableViewController: UITableViewController, StoryboardInstantiable {
    
    var mediatingController: ProductsMediatingController!
    
    var nextPageLoadingSpinner: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func updateLoading(_ loading: Bool) {
        if loading && nextPageLoadingSpinner == nil {
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        } else if !loading {
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = nil
            tableView.tableFooterView = nil
        }
    }
    
    // MARK: - Private
    
    private func setupViews() {
        tableView.estimatedRowHeight = ProductItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func bind(to mediatingController: ProductsMediatingController) {
        mediatingController.items.observe(on: self) { [weak self] _ in
            self?.reload()
        }
        mediatingController.loading.observe(on: self) { [weak self] loading in
            self?.updateLoading(loading)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProductsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediatingController.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProductItemCell = tableView.dequeueReusableCell(at: indexPath)
        
        cell.fill(with: mediatingController.items.value[indexPath.row])
        
        if indexPath.row == mediatingController.items.value.count - 1 {
            mediatingController.didLoadNextPage()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mediatingController.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mediatingController.didSelectItem(at: indexPath.row)
    }
}
