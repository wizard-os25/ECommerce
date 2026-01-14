//
//  OrderViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import UIKit
import StripePaymentSheet

final class OrderViewController: EcoViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Quantity Input
    private let quantityLabel = UILabel()
    private let quantityContainerView = UIView()
    private let quantityMinusButton = UIButton(type: .system)
    private let quantityTextField = UITextField()
    private let quantityPlusButton = UIButton(type: .system)
    
    // Address Fields
    private let addressLabel = UILabel()
    private let addressTextField = EcoTextField()
    
    private let contactPersonNameLabel = UILabel()
    private let contactPersonNameTextField = EcoTextField()
    
    private let contactPersonNumberLabel = UILabel()
    private let contactPersonNumberTextField = EcoTextField()
    
    // Choose Location Saved Label
    private let chooseLocationSavedLabel = UILabel()
    
    // Order Note
    private let orderNoteLabel = UILabel()
    private let orderNoteTextView = ECoTextView()
    
    // Payment Card Section
    private let paymentCardLabel = UILabel()
    private var addPaymentCardButton = EcoButton()
    
    // Place Order Button
    private var placeOrderButton: EcoButton!
    
    private var orderController: OrderController! {
        get { controller as? OrderController }
    }
    
    // Store selected address
    private var selectedAddress: Address?
    private var quantity: Int = 1
    
    // CardViewController for location list popup
    private var locationListCardViewController: CardViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with orderController: OrderController
    ) -> OrderViewController {
        let view = OrderViewController.instantiateViewController()
        view.controller = orderController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupFormFields()
        bindOrderSpecific()
        loadInitialQuantity()
        orderController.didLoadView()
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindOrderSpecific()
    }
    
    override func applyNavigation(_ state: EcoNavigationState) {
        super.applyNavigation(state)
        DispatchQueue.main.async { [weak self] in
            if let navBarController = self?.navigationBarViewController?.controller as? DefaultEcoNavigationBarController {
                navBarController.onLeftItemTap = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Order-Specific Binding
    
    private func bindOrderSpecific() {
        orderController.selectedPaymentCard.observe(on: self) { [weak self] card in
            self?.updatePaymentCardButton(card: card)
        }
        
        orderController.isOrderPlaced.observe(on: self) { [weak self] isPlaced in
            if isPlaced {
                self?.handleOrderPlaced()
            }
        }
        
        orderController.error.observe(on: self) { [weak self] error in
            guard let self = self, let error = error else { return }
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        
        orderController.loading.observe(on: self) { [weak self] isLoading in
            guard let self = self, let placeOrderButton = self.placeOrderButton else { return }
            placeOrderButton.setLoading(isLoading)
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Scroll View
        scrollView.keyboardDismissMode = .onDrag
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Content View
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupFormFields() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.tokenSpacing16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        // Quantity Label
        quantityLabel.text = "Quantity"
        quantityLabel.font = Typography.fontBold16
        quantityLabel.textColor = Colors.tokenDark100
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(quantityLabel)
        
        // Quantity Container
        quantityContainerView.backgroundColor = Colors.tokenDark02
        quantityContainerView.layer.cornerRadius = BorderRadius.tokenBorderRadius12
        quantityContainerView.layer.borderWidth = Sizing.tokenSizing01
        quantityContainerView.layer.borderColor = Colors.tokenDark10.cgColor
        quantityContainerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(quantityContainerView)
        
        // Quantity Input Setup
        setupQuantityInput()
        
        // Address
        setupField(
            label: addressLabel,
            textField: addressTextField,
            title: "Address",
            iconName: "location.fill",
            stackView: stackView
        )
        addressTextField.placeholder = "Enter delivery address"
        
        // Contact Person Name
        setupField(
            label: contactPersonNameLabel,
            textField: contactPersonNameTextField,
            title: "Contact Person Name",
            iconName: "person.fill",
            stackView: stackView
        )
        contactPersonNameTextField.placeholder = "Contact Person Name"
        
        // Contact Person Number
        setupField(
            label: contactPersonNumberLabel,
            textField: contactPersonNumberTextField,
            title: "Contact Person Number",
            iconName: "phone.fill",
            stackView: stackView
        )
        contactPersonNumberTextField.placeholder = "Contact Person Number"
        contactPersonNumberTextField.keyboardType = .phonePad
        
        // Choose Location Saved Label
        chooseLocationSavedLabel.text = "Choose location saved"
        chooseLocationSavedLabel.font = Typography.fontRegular14
        chooseLocationSavedLabel.textColor = Colors.tokenGreen100
        chooseLocationSavedLabel.isUserInteractionEnabled = true
        chooseLocationSavedLabel.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseLocationSavedTapped))
        chooseLocationSavedLabel.addGestureRecognizer(tapGesture)
        stackView.addArrangedSubview(chooseLocationSavedLabel)
        
        // Order Note
        orderNoteLabel.text = "Order Note (Optional)"
        orderNoteLabel.font = Typography.fontBold16
        orderNoteLabel.textColor = Colors.tokenDark100
        orderNoteLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(orderNoteLabel)
        
        orderNoteTextView.type = .advanced
        orderNoteTextView.placeholder = "Add any special instructions..."
        orderNoteTextView.isAllowNewLine = true
        orderNoteTextView.maxLength = 500
        orderNoteTextView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(orderNoteTextView)
        
        // Payment Card Section
        paymentCardLabel.text = "Payment Method"
        paymentCardLabel.font = Typography.fontBold16
        paymentCardLabel.textColor = Colors.tokenDark100
        paymentCardLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(paymentCardLabel)
        
        addPaymentCardButton = EcoButton.secondary(title: "Add New Card")
        addPaymentCardButton.ecoDelegate = self
        addPaymentCardButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addPaymentCardButton)
        
        // Place Order Button
        placeOrderButton = EcoButton.authButton(title: "Place Order")
        placeOrderButton.ecoDelegate = self
        placeOrderButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(placeOrderButton)
        
        // Stack View Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.tokenSpacing22),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.tokenSpacing22),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.tokenSpacing22),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.tokenSpacing40),
            
            // Quantity Container height
            quantityContainerView.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            
            // Text Field heights
            addressTextField.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            contactPersonNameTextField.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            contactPersonNumberTextField.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            
            // Order Note TextView height
            orderNoteTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // Payment Card Button height
            addPaymentCardButton.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            
            // Place Order Button height
            placeOrderButton.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56)
        ])
    }
    
    private func setupQuantityInput() {
        // Minus Button
        quantityMinusButton.setTitle("-", for: .normal)
        quantityMinusButton.titleLabel?.font = Typography.fontBold22
        quantityMinusButton.setTitleColor(Colors.tokenDark100, for: .normal)
        quantityMinusButton.addTarget(self, action: #selector(quantityMinusTapped), for: .touchUpInside)
        quantityMinusButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Text Field
        quantityTextField.text = "1"
        quantityTextField.textAlignment = .center
        quantityTextField.font = Typography.fontMedium16
        quantityTextField.textColor = Colors.tokenDark100
        quantityTextField.keyboardType = .numberPad
        quantityTextField.borderStyle = .none
        quantityTextField.backgroundColor = .clear
        quantityTextField.delegate = self
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Plus Button
        quantityPlusButton.setTitle("+", for: .normal)
        quantityPlusButton.titleLabel?.font = Typography.fontBold22
        quantityPlusButton.setTitleColor(Colors.tokenDark100, for: .normal)
        quantityPlusButton.addTarget(self, action: #selector(quantityPlusTapped), for: .touchUpInside)
        quantityPlusButton.translatesAutoresizingMaskIntoConstraints = false
        
        quantityContainerView.addSubview(quantityMinusButton)
        quantityContainerView.addSubview(quantityTextField)
        quantityContainerView.addSubview(quantityPlusButton)
        
        NSLayoutConstraint.activate([
            quantityMinusButton.leadingAnchor.constraint(equalTo: quantityContainerView.leadingAnchor, constant: Spacing.tokenSpacing16),
            quantityMinusButton.centerYAnchor.constraint(equalTo: quantityContainerView.centerYAnchor),
            quantityMinusButton.widthAnchor.constraint(equalToConstant: 32),
            quantityMinusButton.heightAnchor.constraint(equalToConstant: 32),
            
            quantityTextField.centerXAnchor.constraint(equalTo: quantityContainerView.centerXAnchor),
            quantityTextField.centerYAnchor.constraint(equalTo: quantityContainerView.centerYAnchor),
            quantityTextField.widthAnchor.constraint(equalToConstant: 60),
            
            quantityPlusButton.trailingAnchor.constraint(equalTo: quantityContainerView.trailingAnchor, constant: -Spacing.tokenSpacing16),
            quantityPlusButton.centerYAnchor.constraint(equalTo: quantityContainerView.centerYAnchor),
            quantityPlusButton.widthAnchor.constraint(equalToConstant: 32),
            quantityPlusButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupField(
        label: UILabel,
        textField: EcoTextField,
        title: String,
        iconName: String,
        stackView: UIStackView
    ) {
        // Title Label
        label.text = title
        label.font = Typography.fontBold16
        label.textColor = Colors.tokenDark100
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        
        // Text Field
        textField.type = .baseline
        textField.setLeftIcon(iconName, tintColor: Colors.tokenDark60)
        textField.cornerRadius = BorderRadius.tokenBorderRadius12
        textField.backgroundColorColor = Colors.tokenDark02
        textField.borderColor = Colors.tokenDark10
        textField.selectedBorderColor = Colors.tokenRainbowBlueEnd
        textField.errorBorderColor = Colors.tokenRed100
        textField.borderWidth = Sizing.tokenSizing01
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
    }
    
    private func loadInitialQuantity() {
        if let firstItem = orderController.cartItems.value.first {
            quantity = firstItem.quantity
            quantityTextField.text = "\(quantity)"
            updateCartItemsQuantity()
        }
    }
    
    private func updateCartItemsQuantity() {
        guard let firstItem = orderController.cartItems.value.first else { return }
        let updatedCartItems = [CartItem(id: firstItem.id, quantity: quantity)]
        orderController.updateCartItems(updatedCartItems)
    }
    
    // MARK: - Helper Methods
    
    private func updatePaymentCardButton(card: PaymentCard?) {
        if let card = card {
            addPaymentCardButton.setTitle("\(card.displayName) (Tap to change)", for: .normal)
        } else {
            addPaymentCardButton.setTitle("Add New Card", for: .normal)
        }
    }
    
    private func handleOrderPlaced() {
        guard let order = orderController.orderResult.value else { return }
        showAlert(
            title: "Success",
            message: "Order placed successfully! Order ID: \(order.orderId)"
        )
    }
    
    private func showPaymentSheet() {
        // PaymentSheet will be shown here
        // This requires payment intent client_secret which is created after order is placed
        // For now, this is a placeholder
        showAlert(
            title: "Add Payment Method",
            message: "PaymentSheet integration will be implemented after order is placed"
        )
    }
    
    @objc private func chooseLocationSavedTapped() {
        showLocationListPopup()
    }
    
    private func showLocationListPopup() {
        // Prevent opening multiple times
        if let existingCard = locationListCardViewController, existingCard.parent != nil {
            existingCard.show()
            return
        }
        
        // Clean up if exists but not attached
        if locationListCardViewController != nil {
            locationListCardViewController?.detach()
            locationListCardViewController = nil
        }
        
        // Create Card Configuration
        let screenHeight = view.bounds.height
        let cardHeight = screenHeight - 120
        let cardConfig = CardConfiguration(
            expandedHeight: cardHeight,
            collapsedHeight: cardHeight,
            presentationMode: .onDemand,
            enableGesture: true
        )
        
        // Create Card Controller
        let cardController = DefaultCardController(configuration: cardConfig)
        
        // Create Card View Controller
        let cardVC = CardViewController.create(with: cardController)
        cardVC.attach(to: self)
        locationListCardViewController = cardVC
        
        // Create LocationListViewController
        let appDIContainer = AppDIContainer()
        let locationListDIContainer = appDIContainer.makeLocationListDIContainer()
        let locationListVC = locationListDIContainer.makeLocationListViewController()
        
        // Setup callback when address is selected
        if let locationListController = locationListVC.controller as? DefaultLocationListController {
            locationListController.onAddressSelected = { [weak self, weak cardVC] address in
                self?.selectedAddress = address
                
                // Fill form with selected address
                self?.addressTextField.text = address.address
                self?.contactPersonNameTextField.text = address.contactPersonName
                self?.contactPersonNumberTextField.text = address.contactPersonNumber
                
                // Dismiss card
                cardVC?.dismiss()
                if cardVC === self?.locationListCardViewController {
                    self?.locationListCardViewController = nil
                }
            }
        }
        
        // Set LocationListViewController as content
        cardVC.setContent(locationListVC)
        
        // Show card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cardVC.show()
        }
    }
    
    @objc private func quantityMinusTapped() {
        if quantity > 1 {
            quantity -= 1
            quantityTextField.text = "\(quantity)"
            updateCartItemsQuantity()
        }
    }
    
    @objc private func quantityPlusTapped() {
        quantity += 1
        quantityTextField.text = "\(quantity)"
        updateCartItemsQuantity()
    }
}

// MARK: - EcoButtonDelegate

extension OrderViewController: EcoButtonDelegate {
    
    func buttonDidTap(_ button: EcoButton) {
        if button == addPaymentCardButton {
            showPaymentSheet()
        } else if button == placeOrderButton {
            orderController.didTapPlaceOrder(
                address: addressTextField.text ?? "",
                longitude: selectedAddress?.longitude ?? "",
                latitude: selectedAddress?.latitude ?? "",
                contactPersonName: contactPersonNameTextField.text ?? "",
                contactPersonNumber: contactPersonNumberTextField.text ?? "",
                orderNote: orderNoteTextView.text.isEmpty ? nil : orderNoteTextView.text
            )
        }
    }
}

// MARK: - UITextFieldDelegate

extension OrderViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == quantityTextField {
            if let text = textField.text, let value = Int(text), value > 0 {
                quantity = value
                updateCartItemsQuantity()
            } else {
                quantityTextField.text = "\(quantity)"
            }
        }
    }
}
