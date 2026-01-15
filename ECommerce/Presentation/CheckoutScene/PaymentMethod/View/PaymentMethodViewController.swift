//
//  PaymentMethodViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 15/1/26.
//

import UIKit
import StripePaymentSheet

final class PaymentMethodViewController: EcoViewController {
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemBackground
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let orderActionView = OrderActionView()
    
    private var paymentMethodController: PaymentMethodController! {
        get { controller as? PaymentMethodController }
    }
    
    private var paymentSheet: PaymentSheet?
    
    // MARK: - Lifecycle
    
    static func create(
        with paymentMethodController: PaymentMethodController
    ) -> PaymentMethodViewController {
        let view = PaymentMethodViewController.instantiateViewController()
        view.controller = paymentMethodController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSwipeBackEnabled = true
        setupViews()
        bindObservables()
        paymentMethodController.didLoadView()
        
        // Setup callback to show PaymentSheet when payment intent is created (for add new card)
        if let defaultController = paymentMethodController as? DefaultPaymentMethodController {
            defaultController.onShowPaymentSheet = { [weak self] in
                self?.showPaymentSheetIfReady()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paymentMethodController.onViewWillAppear()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PaymentCardCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddCardCell")
        
        view.addSubview(tableView)
        view.addSubview(orderActionView)
        
        orderActionView.delegate = self
        orderActionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup OrderActionView để hiển thị đẹp - chỉ hiển thị button, không có top row và left item
        orderActionView.topLeftLabelText = nil
        orderActionView.topRightLabelText = nil
        orderActionView.leftItemType = .none
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: orderActionView.topAnchor),
            
            orderActionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orderActionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orderActionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Chiều cao cố định 52pt cho button view
            orderActionView.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        // Điều chỉnh OrderActionView để hiển thị đẹp với chiều cao 52pt
        adjustOrderActionViewForCompactHeight()
        
        updateOrderActionView()
    }
    
    private func adjustOrderActionViewForCompactHeight() {
        // Điều chỉnh OrderActionView để hiển thị đẹp với chiều cao 52pt
        // Tìm và điều chỉnh constraints của OrderActionView để giảm padding
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Tìm containerStackView trong OrderActionView
            for subview in self.orderActionView.subviews {
                if let stackView = subview as? UIStackView {
                    // Điều chỉnh constraints của stackView
                    for constraint in self.orderActionView.constraints {
                        if (constraint.firstItem === stackView || constraint.secondItem === stackView) {
                            // Giảm top padding từ 12pt xuống 0pt
                            if constraint.firstAttribute == .top && constraint.constant == Spacing.tokenSpacing12 {
                                constraint.constant = 0
                            }
                            // Giảm bottom padding từ -12pt xuống 0pt
                            if constraint.firstAttribute == .bottom && constraint.constant == -Spacing.tokenSpacing12 {
                                constraint.constant = 0
                            }
                        }
                    }
                }
            }
            
            // Điều chỉnh button height từ 56pt xuống 52pt
            self.findAndAdjustButtonHeight(in: self.orderActionView)
        }
    }
    
    private func findAndAdjustButtonHeight(in view: UIView) {
        for subview in view.subviews {
            if let button = subview as? EcoButton {
                // Điều chỉnh button height constraint
                for constraint in button.constraints {
                    if constraint.firstAttribute == .height && constraint.constant == Sizing.tokenSizing56 {
                        constraint.constant = 52
                    }
                }
                // Tìm constraints từ parent
                if let parentView = button.superview {
                    for constraint in parentView.constraints {
                        if (constraint.firstItem === button || constraint.secondItem === button) &&
                            constraint.firstAttribute == .height && constraint.constant == Sizing.tokenSizing56 {
                            constraint.constant = 52
                        }
                    }
                }
            } else {
                // Recursive search
                findAndAdjustButtonHeight(in: subview)
            }
        }
    }
    
    private func bindObservables() {
        paymentMethodController.paymentCards.observe(on: self) { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateOrderActionView()
        }
        
        paymentMethodController.selectedCard.observe(on: self) { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateOrderActionView()
        }
        
        paymentMethodController.loading.observe(on: self) { [weak self] isLoading in
            self?.orderActionView.isLoading = isLoading
        }
        
        paymentMethodController.error.observe(on: self) { [weak self] error in
            guard let error = error else { return }
            self?.showAlert(title: "Error", message: error.localizedDescription)
        }
        
        // PaymentSheet sẽ được hiển thị tự động trong viewDidLoad vì đã có clientSecret
    }
    
    private func updateOrderActionView() {
        let hasSelectedCard = paymentMethodController.selectedCard.value != nil
        orderActionView.buttonTitle = "Pay"
        orderActionView.isButtonEnabled = hasSelectedCard
        orderActionView.leftItemType = .none
    }
    
    // MARK: - Payment Sheet
    
    private func showPaymentSheetIfReady() {
        guard let defaultController = paymentMethodController as? DefaultPaymentMethodController else { return }
        
        defaultController.getPaymentInfo { [weak self] clientSecret, customerId, ephemeralKey in
            guard let self = self,
                  let clientSecret = clientSecret else {
                print("⚠️ [PaymentMethodViewController] Missing client secret")
                return
            }
            
            self.preparePaymentSheet(clientSecret: clientSecret, customerId: customerId, ephemeralKey: ephemeralKey)
        }
    }
    
    private func preparePaymentSheet(clientSecret: String, customerId: String?, ephemeralKey: String?) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "My Shop"
        
        // Chỉ set customer nếu có customerId và ephemeralKey
        if let customerId = customerId, let ephemeralKey = ephemeralKey {
            configuration.customer = .init(
                id: customerId,
                ephemeralKeySecret: ephemeralKey
            )
        }
        
        configuration.allowsDelayedPaymentMethods = false
        
        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
        
        paymentSheet?.present(from: self) { [weak self] result in
            guard let self = self else { return }
            
            self.handlePaymentSheetResult(result)
        }
    }
    
    private func handlePaymentSheetResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            // Payment completed successfully
            print("✅ Payment completed successfully")
            // Confirm payment with backend
            confirmPaymentWithBackend()
        case .canceled:
            // User canceled
            print("❌ User canceled payment")
        case .failed(let error):
            // Payment failed
            print("⚠️ Payment failed: \(error.localizedDescription)")
            showAlert(title: "Payment Failed", message: error.localizedDescription)
        }
    }
    
    private func confirmPaymentWithBackend() {
        guard let defaultController = paymentMethodController as? DefaultPaymentMethodController,
              let paymentIntentId = defaultController.getPaymentIntentId() else {
            showAlert(title: "Error", message: "Payment intent ID not found")
            return
        }
        
        // Call confirm payment API
        defaultController.confirmPayment(paymentIntentId: paymentIntentId) { [weak self] success in
            if success {
                // Show success message
                self?.showSuccessAlert()
            } else {
                self?.showAlert(title: "Error", message: "Failed to confirm payment")
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "Payment completed successfully!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Navigate back or to success screen
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showAddCardPaymentSheet() {
        // Trigger controller to create setup payment intent
        // Controller will call onPaymentSuccess callback when ready
        paymentMethodController.didTapAddNewCard()
    }
    
    private func notifyBackendSuccess() {
        guard let defaultController = paymentMethodController as? DefaultPaymentMethodController,
              let paymentIntentId = defaultController.getPaymentIntentId() else {
            return
        }
        
        // Payment is already confirmed by Stripe SDK
        // Navigate to success screen
        print("✅ Payment completed successfully")
        // TODO: Navigate to success screen
    }
}

// MARK: - UITableViewDataSource

extension PaymentMethodViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethodController.paymentCards.value.count + 1 // +1 for "Add new card" row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cards = paymentMethodController.paymentCards.value
        
        if indexPath.row < cards.count {
            // Saved card cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardCell", for: indexPath)
            let card = cards[indexPath.row]
            let isSelected = paymentMethodController.selectedCard.value?.id == card.id
            
            cell.textLabel?.text = card.displayName
            cell.textLabel?.font = Typography.fontRegular16
            cell.accessoryType = isSelected ? .checkmark : .none
            cell.selectionStyle = .default
            
            return cell
        } else {
            // Add new card cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardCell", for: indexPath)
            cell.textLabel?.text = "Add new card"
            cell.textLabel?.font = Typography.fontBold16
            cell.textLabel?.textColor = Colors.tokenBrown
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension PaymentMethodViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cards = paymentMethodController.paymentCards.value
        
        if indexPath.row < cards.count {
            // Select card
            let card = cards[indexPath.row]
            paymentMethodController.didSelectCard(card)
        } else {
            // Add new card - show PaymentSheet
            showAddCardPaymentSheet()
        }
    }
}

// MARK: - OrderActionViewDelegate

extension PaymentMethodViewController: OrderActionViewDelegate {
    
    func orderActionViewDidTapAction(_ view: OrderActionView) {
        paymentMethodController.didTapPay()
    }
    
    func orderActionViewDidTapLeftItem(_ view: OrderActionView) {
        // No action needed
    }
}
