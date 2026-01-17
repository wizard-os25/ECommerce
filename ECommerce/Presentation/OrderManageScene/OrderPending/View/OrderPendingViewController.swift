//
//  OrderPendingViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import UIKit

final class OrderPendingViewController: EcoViewController {
    
    @IBOutlet private weak var orderPendingTableView: UITableView!
    
    private var orderPendingController: OrderPendingController! {
        get { controller as? OrderPendingController }
    }
    
    // MARK: - Lifecycle
    
    static func create(
        with orderPendingController: OrderPendingController
    ) -> OrderPendingViewController {
        let view = OrderPendingViewController.instantiateViewController()
        view.controller = orderPendingController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindOrderPendingSpecific()
        setupNavigation()
        orderPendingController.didLoad()
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindOrderPendingSpecific()
    }
    
    // MARK: - OrderPending-Specific Binding
    
    private func bindOrderPendingSpecific() {
        orderPendingController.items.observe(on: self) { [weak self] _ in
            self?.orderPendingTableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    private func setupNavigation() {
        if let controller = controller as? DefaultOrderPendingController {
            controller.onSelectOrderItem = { [weak self] item in
                self?.navigateToOrderDetail(orderId: item.id)
            }
        }
    }
    
    private func navigateToOrderDetail(orderId: Int) {
        guard let navigationController = navigationController else { return }
        let appDIContainer = AppDIContainer()
        let orderDetailDIContainer = appDIContainer.makeOrderDetailDIContainer()
        let orderDetailVC = orderDetailDIContainer.makeOrderDetailViewController(orderId: orderId)
        navigationController.pushViewController(orderDetailVC, animated: true)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        orderPendingTableView.delegate = self
        orderPendingTableView.dataSource = self
        //orderPendingTableView.register(cell: OrderPendingCell.self)
        orderPendingTableView.estimatedRowHeight = OrderPendingCell.height
        orderPendingTableView.rowHeight = UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource

extension OrderPendingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderPendingController.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OrderPendingCell = tableView.dequeueReusableCell(at: indexPath)
        
        // Guard để đảm bảo có data
        guard indexPath.row < orderPendingController.items.value.count else {
            print("⚠️ [OrderPendingViewController] Index out of range: \(indexPath.row)")
            return cell
        }
        
        let item = orderPendingController.items.value[indexPath.row]
        cell.fill(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OrderPendingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        orderPendingController.didSelectItem(at: indexPath.row)
    }
}
