//
//  AddressViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import UIKit

final class AddressViewController: EcoViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Form Fields
    private let contactPersonNameLabel = UILabel()
    private let contactPersonNameTextField = EcoTextField()
    
    private let contactPersonNumberLabel = UILabel()
    private let contactPersonNumberTextField = EcoTextField()
    
    private let addressLabel = UILabel()
    private let addressSearchTextField = EcoSearchTextField()
    private let useCurrentLocationStack = UIStackView()
    private let useCurrentLocationIcon = UIImageView()
    private let useCurrentLocationLabel = UILabel()
    
    private let defaultAddressStack = UIStackView()
    private let defaultAddressCheckbox = UIImageView()
    private let defaultAddressLabel = UILabel()
    private var isCheckboxSelected: Bool = false
    
    private var saveButton: EcoButton!
    
    private var addressController: AddressController! {
        get { controller as? AddressController }
    }
    
    // MARK: - Lifecycle
    
    static func create(
        with addressController: AddressController
    ) -> AddressViewController {
        let view = AddressViewController.instantiateViewController()
        view.controller = addressController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSwipeBackEnabled = true
        setupViews()
        setupFormFields() // Must be called before bindAddressSpecific() to initialize saveButton
        bindAddressSpecific()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navBarView = navigationBarViewController?.view {
            view.bringSubviewToFront(navBarView)
            navBarView.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindAddressSpecific()
    }
    
    override func applyNavigation(_ state: EcoNavigationState) {
        super.applyNavigation(state)
        // Override left item tap callback to pop back normally
        DispatchQueue.main.async { [weak self] in
            if let navBarController = self?.navigationBarViewController?.controller as? DefaultEcoNavigationBarController {
                navBarController.onLeftItemTap = { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Address-Specific Binding
    
    private func bindAddressSpecific() {
        addressController.isSaveSuccess.observe(on: self) { [weak self] isSuccess in
            if isSuccess {
                // Success state is handled via successMessage Observable
            }
        }
        
        addressController.successMessage.observe(on: self) { [weak self] message in
            guard let message = message, !message.isEmpty else { return }
            self?.showSuccessAlert(message: message)
        }
        
        addressController.error.observe(on: self) { [weak self] error in
            guard let self = self, let error = error else { return }
            self.showAlert(title: "Error", message: error.localizedDescription)
        }
        
        addressController.loading.observe(on: self) { [weak self] isLoading in
            guard let self = self, let saveButton = self.saveButton else { return }
            saveButton.setLoading(isLoading)
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        title = addressController.screenTitle
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
        let navBarHeight = addressController.navigationBarInitialHeight
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: navBarHeight),
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
        
        // Contact Person Name
        setupField(
            label: contactPersonNameLabel,
            textField: contactPersonNameTextField,
            title: "Contact Person Name",
            iconName: "person.fill",
            stackView: stackView
        )
        
        // Contact Person Number
        setupField(
            label: contactPersonNumberLabel,
            textField: contactPersonNumberTextField,
            title: "Contact Person Number",
            iconName: "phone.fill",
            stackView: stackView
        )
        contactPersonNumberTextField.keyboardType = .phonePad
        
        // Address
        addressLabel.text = "Address"
        addressLabel.font = Typography.fontBold16
        addressLabel.textColor = Colors.tokenDark100
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addressLabel)
        
        addressSearchTextField.isNavigationStyle = false
        addressSearchTextField.placeholder = "Enter address"
        addressSearchTextField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addressSearchTextField)
        
        // Use Current Location
        setupUseCurrentLocation(stackView: stackView)
        
        // Default Address Checkbox
        setupDefaultAddressCheckbox(stackView: stackView)
        
        // Save Button - Use authButton style like Login
        saveButton = EcoButton.authButton(title: "Save")
        saveButton.ecoDelegate = self
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(saveButton)
        
        // Stack View Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.tokenSpacing22),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.tokenSpacing22),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.tokenSpacing22),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.tokenSpacing40),
            
            // Address Search TextField height
            addressSearchTextField.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56),
            
            // Save Button height (same as Login)
            saveButton.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56)
        ])
    }
    
    private func setupField(
        label: UILabel,
        textField: EcoTextField,
        title: String,
        iconName: String,
        stackView: UIStackView
    ) {
        // Title Label (bold, above text field)
        label.text = title
        label.font = Typography.fontBold16
        label.textColor = Colors.tokenDark100
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        
        // Text Field (styled like Login/SignUp)
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
        
        // Text Field height constraint
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing56)
        ])
    }
    
    private func setupUseCurrentLocation(stackView: UIStackView) {
        useCurrentLocationStack.axis = .horizontal
        useCurrentLocationStack.spacing = Spacing.tokenSpacing08
        useCurrentLocationStack.alignment = .center
        useCurrentLocationStack.translatesAutoresizingMaskIntoConstraints = false
        
        useCurrentLocationIcon.image = UIImage(systemName: "location.fill")
        useCurrentLocationIcon.tintColor = Colors.tokenRainbowBlueEnd
        useCurrentLocationIcon.contentMode = .scaleAspectFit
        
        useCurrentLocationLabel.text = "Use my current location"
        useCurrentLocationLabel.font = Typography.fontRegular14
        useCurrentLocationLabel.textColor = Colors.tokenRainbowBlueEnd
        
        useCurrentLocationStack.addArrangedSubview(useCurrentLocationIcon)
        useCurrentLocationStack.addArrangedSubview(useCurrentLocationLabel)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(useCurrentLocationTapped))
        useCurrentLocationStack.addGestureRecognizer(tapGesture)
        useCurrentLocationStack.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(useCurrentLocationStack)
        
        NSLayoutConstraint.activate([
            useCurrentLocationIcon.widthAnchor.constraint(equalToConstant: 20),
            useCurrentLocationIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupDefaultAddressCheckbox(stackView: UIStackView) {
        defaultAddressStack.axis = .horizontal
        defaultAddressStack.spacing = Spacing.tokenSpacing08
        defaultAddressStack.alignment = .center
        defaultAddressStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Square Checkbox using ECoTick style with custom icons
        let bundle = Bundle(for: ECoTick.self)
        defaultAddressCheckbox.image = HelperFunction.getImage(named: "ic_checkbox_uncheck_24", in: bundle)
        defaultAddressCheckbox.contentMode = .scaleAspectFit
        defaultAddressCheckbox.isUserInteractionEnabled = true
        defaultAddressCheckbox.translatesAutoresizingMaskIntoConstraints = false
        
        // Label with italic font
        defaultAddressLabel.text = "Set as default shipping address"
        defaultAddressLabel.font = UIFont.italicSystemFont(ofSize: 14) // Italic font
        defaultAddressLabel.textColor = Colors.tokenDark100
        defaultAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        defaultAddressStack.addArrangedSubview(defaultAddressCheckbox)
        defaultAddressStack.addArrangedSubview(defaultAddressLabel)
        
        // Add tap gesture to stack view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(defaultAddressTapped))
        defaultAddressStack.addGestureRecognizer(tapGesture)
        defaultAddressStack.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(defaultAddressStack)
        
        // Checkbox size constraint (24x24 for ic_checkbox_uncheck_24)
        NSLayoutConstraint.activate([
            defaultAddressCheckbox.widthAnchor.constraint(equalToConstant: Sizing.tokenSizing24),
            defaultAddressCheckbox.heightAnchor.constraint(equalToConstant: Sizing.tokenSizing24)
        ])
    }
    
    private func updateCheckboxImage() {
        let bundle = Bundle(for: ECoTick.self)
        if isCheckboxSelected {
            // Use ic_right_check_16_green when selected
            defaultAddressCheckbox.image = HelperFunction.getImage(named: "ic_right_check_16_green", in: bundle)
        } else {
            // Use ic_checkbox_uncheck_24 when unselected
            defaultAddressCheckbox.image = HelperFunction.getImage(named: "ic_checkbox_uncheck_24", in: bundle)
        }
    }
    
    // MARK: - Actions
    
    @objc private func useCurrentLocationTapped() {
        addressController.didTapUseCurrentLocation()
    }
    
    @objc private func defaultAddressTapped() {
        isCheckboxSelected.toggle()
        updateCheckboxImage()
    }
    
    // MARK: - Error Handler Override
    
    override func handleError(_ error: Error?) {
        guard let error = error else { return }
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    private func showSuccessAlert(message: String) {
        addressController.successMessage.value = nil
        showAlert(
            title: "Success",
            message: message,
            completion: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
    }
}

// MARK: - EcoButtonDelegate

extension AddressViewController: EcoButtonDelegate {
    
    func buttonDidTap(_ button: EcoButton) {
        guard button == saveButton else { return }
        
        addressController.didTapSave(
            contactPersonName: contactPersonNameTextField.text ?? "",
            contactPersonNumber: contactPersonNumberTextField.text ?? "",
            address: addressSearchTextField.text ?? "",
            addressType: "home", // Default address type
            longitude: "", // Will be set by location if needed
            latitude: "", // Will be set by location if needed
            isDefault: isCheckboxSelected
        )
    }
}
