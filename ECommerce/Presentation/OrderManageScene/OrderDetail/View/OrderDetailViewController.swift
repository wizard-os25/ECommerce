//
//  OrderDetailViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import UIKit

final class OrderDetailViewController: EcoViewController {
    
    @IBOutlet private weak var orderDetailTableView: UITableView!
    @IBOutlet private weak var cancelOrderButton: UIButton!
    
    private var orderDetailController: OrderDetailController! {
        get { controller as? OrderDetailController }
    }
    
    // MARK: - Lifecycle
    
    static func create(
        with orderDetailController: OrderDetailController
    ) -> OrderDetailViewController {
        let view = OrderDetailViewController.instantiateViewController()
        view.controller = orderDetailController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindOrderDetailSpecific()
        setupCancelButton()
        orderDetailController.didLoad()
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindOrderDetailSpecific()
    }
    
    // MARK: - OrderDetail-Specific Binding
    
    private func bindOrderDetailSpecific() {
        orderDetailController.orderDetail.observe(on: self) { [weak self] _ in
            self?.orderDetailTableView.reloadData()
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        orderDetailTableView.delegate = self
        orderDetailTableView.dataSource = self
        // Register cells - sẽ được cấu hình trong Storyboard
        self.orderDetailTableView.register(cell: OrderDetailAddressCell.self)
        self.orderDetailTableView.register(cell: OrderDetailOtherInfoCell.self)
        self.orderDetailTableView.register(cell: OrderDetailProductCell.self)
        
        orderDetailTableView.estimatedRowHeight = 100
        orderDetailTableView.rowHeight = UITableView.automaticDimension
        
        // Setup cancel button
        cancelOrderButton.setTitle("Cancel order", for: .normal)
        cancelOrderButton.addTarget(self, action: #selector(cancelOrderTapped), for: .touchUpInside)
    }
    
    private func setupCancelButton() {
        cancelOrderButton.backgroundColor = .systemRed
        cancelOrderButton.setTitleColor(.white, for: .normal)
        cancelOrderButton.layer.cornerRadius = 8
        cancelOrderButton.titleLabel?.font = Typography.fontMedium16
    }
    
    @objc private func cancelOrderTapped() {
        orderDetailController.didCancelOrder()
    }
}

// MARK: - UITableViewDataSource

extension OrderDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderDetail = orderDetailController.orderDetail.value else { return 0 }
        
        switch section {
        case 0: // Address receive
            return 1
        case 1: // Order detail
            return orderDetail.details.count
        case 2: // Other info
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let orderDetail = orderDetailController.orderDetail.value else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0: // Address receive
            let cell: OrderDetailAddressCell = tableView.dequeueReusableCell(at: indexPath)
            cell.fill(with: orderDetail.shippingAddress)
            return cell
            
        case 1: // Order detail
            let cell: OrderDetailProductCell = tableView.dequeueReusableCell(at: indexPath)
            let detailItem = orderDetail.details[indexPath.row]
            cell.fill(with: detailItem)
            return cell
            
        case 2: // Other info
            let cell: OrderDetailOtherInfoCell = tableView.dequeueReusableCell(at: indexPath)
            cell.fill(with: orderDetail)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Address receive"
        case 1:
            return "Order detail"
        case 2:
            return "Other info"
        default:
            return nil
        }
    }
}

// MARK: - UITableViewDelegate

extension OrderDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - OrderDetail Extensions

extension OrderDetail {
    var formattedPaymentMethod: String {
        guard let method = paymentMethod, !method.isEmpty else {
            return "N/A"
        }
        return method.capitalized
    }
    
    func formatDate(_ dateString: String) -> String {
        // Parse format: "2026-01-16 20:21:26"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US")
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
}
