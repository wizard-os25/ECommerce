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
    private let chooseOnMapButton = UIButton(type: .system) // Changed from UILabel to UIButton for UIMenu support
    
    private let defaultAddressStack = UIStackView()
    private let defaultAddressCheckbox = UIImageView()
    private let defaultAddressLabel = UILabel()
    private var isCheckboxSelected: Bool = false
    
    private var saveButton: EcoButton!
    
    private var addressController: AddressController! {
        get { controller as? AddressController }
    }
    
    // Store reference to CardViewController to prevent opening multiple times
    private var cardViewController: CardViewController?
    
    // Lưu tọa độ để dùng khi save
    private var selectedLatitude: String = ""
    private var selectedLongitude: String = ""
    
    // Lưu address type từ MapViewController
    private var selectedAddressType: String = "home" // Default: "home"
    
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
        
        // Setup right bar button callback in controller - action from .icon() will call this
        if let defaultController = addressController as? DefaultAddressController {
            defaultController.onRightBarButtonTap = { [weak self] in
                self?.showLocationList()
            }
        }
    }
    
    // MARK: - Address-Specific Binding
    
    private func bindAddressSpecific() {
        // Setup callback for current location
        if let defaultController = addressController as? DefaultAddressController {
            defaultController.onCurrentLocationReceived = { [weak self] address, latitude, longitude in
                guard let self = self else { return }
                
                // Lưu tọa độ
                self.selectedLatitude = latitude
                self.selectedLongitude = longitude
                
                // Lưu address type mặc định là "shipping"
                self.selectedAddressType = "shipping"
                
                // Điền vào addressSearchTextField
                self.addressSearchTextField.text = address
                
                // Thay đổi button "Choose on Map" thành "Shipping address" và enable menu
                self.updateAddressTypeButton(text: "Shipping address", addressType: "shipping")
            }
        }
        
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
        useCurrentLocationStack.distribution = .fill
        useCurrentLocationStack.translatesAutoresizingMaskIntoConstraints = false
        
        useCurrentLocationIcon.image = UIImage(systemName: "location.fill")
        useCurrentLocationIcon.tintColor = Colors.tokenRainbowBlueEnd
        useCurrentLocationIcon.contentMode = .scaleAspectFit
        
        useCurrentLocationLabel.text = "Use my current location"
        useCurrentLocationLabel.font = Typography.fontRegular14
        useCurrentLocationLabel.textColor = Colors.tokenRainbowBlueEnd
        
        // Choose on Map button (can be tapped to open map, or long pressed to show address type menu)
        chooseOnMapButton.setTitle("Choose on Map", for: .normal)
        chooseOnMapButton.titleLabel?.font = UIFont.italicSystemFont(ofSize: 14) // Italic font
        chooseOnMapButton.setTitleColor(Colors.tokenRainbowBlueEnd, for: .normal)
        chooseOnMapButton.contentHorizontalAlignment = .right
        
        // Add underline to title
        let title = "Choose on Map"
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        chooseOnMapButton.setAttributedTitle(attributedTitle, for: .normal)
        
        // Setup menu for address type selection (shows on long press)
        updateAddressTypeButtonMenu()
        
        // Add tap gesture for "Choose on Map" (to open map)
        let chooseOnMapTapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseOnMapTapped))
        chooseOnMapButton.addGestureRecognizer(chooseOnMapTapGesture)
        
        useCurrentLocationStack.addArrangedSubview(useCurrentLocationIcon)
        useCurrentLocationStack.addArrangedSubview(useCurrentLocationLabel)
        useCurrentLocationStack.addArrangedSubview(chooseOnMapButton)
        
        // Add tap gesture for use current location (only on icon and label area)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(useCurrentLocationTapped))
        useCurrentLocationStack.addGestureRecognizer(tapGesture)
        useCurrentLocationStack.isUserInteractionEnabled = true
        
        stackView.addArrangedSubview(useCurrentLocationStack)
        
        NSLayoutConstraint.activate([
            useCurrentLocationIcon.widthAnchor.constraint(equalToConstant: 20),
            useCurrentLocationIcon.heightAnchor.constraint(equalToConstant: 20),
            chooseOnMapButton.leadingAnchor.constraint(greaterThanOrEqualTo: useCurrentLocationLabel.trailingAnchor, constant: Spacing.tokenSpacing08)
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
    
    // MARK: - Address Type Menu
    
    private func updateAddressTypeButtonMenu() {
        // Only show menu if location has been selected (has latitude/longitude)
        guard !selectedLatitude.isEmpty && !selectedLongitude.isEmpty else {
            if #available(iOS 14.0, *) {
                chooseOnMapButton.menu = nil
            } else {
                // Fallback on earlier versions
            }
            return
        }
        
        // Create menu items for address type selection
        let shippingAction = UIAction(title: "Shipping address", handler: { [weak self] _ in
            self?.didSelectAddressType("shipping", displayText: "Shipping address")
        })
        
        let shopAction = UIAction(title: "Shop address", handler: { [weak self] _ in
            self?.didSelectAddressType("shop", displayText: "Shop address")
        })
        
        let otherAction = UIAction(title: "Other", handler: { [weak self] _ in
            self?.didSelectAddressType("other", displayText: "Other")
        })
        
        // Create menu
        let menu = UIMenu(title: "", children: [shippingAction, shopAction, otherAction])
        
        // Set menu to button (shows on long press)
        if #available(iOS 14.0, *) {
            chooseOnMapButton.menu = menu
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 14.0, *) {
            chooseOnMapButton.showsMenuAsPrimaryAction = false
        } else {
            // Fallback on earlier versions
        } // Only show on long press, tap still works for opening map
    }
    
    private func updateAddressTypeButton(text: String, addressType: String) {
        // Update button title with underline
        let attributedTitle = NSMutableAttributedString(string: text)
        attributedTitle.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        chooseOnMapButton.setAttributedTitle(attributedTitle, for: .normal)
        
        // Enable menu interaction (only show menu if location has been selected)
        chooseOnMapButton.isEnabled = true
        updateAddressTypeButtonMenu()
    }
    
    private func didSelectAddressType(_ addressType: String, displayText: String) {
        // Update selected address type
        selectedAddressType = addressType
        
        // Update button text
        updateAddressTypeButton(text: displayText, addressType: addressType)
    }
    
    @objc private func chooseOnMapTapped() {
        // Create MapController
        let mapController = DefaultMapController()
        
        // Create MapViewController
        let mapViewController = MapViewController.create(with: mapController)
        
        // Setup callback khi chọn vị trí (sẽ được gọi khi back về AddressViewController)
        mapViewController.onLocationSelected = { [weak self] address, latitude, longitude, addressType in
            guard let self = self else { return }
            
            // Lưu tọa độ
            self.selectedLatitude = latitude
            self.selectedLongitude = longitude
            
            // Lưu address type
            self.selectedAddressType = addressType
            
            // Điền vào addressSearchTextField
            self.addressSearchTextField.text = address
            
            // Update button text based on selected address type
            let displayText: String
            switch addressType {
            case "shipping":
                displayText = "Shipping address"
            case "shop":
                displayText = "Shop address"
            case "other":
                displayText = "Other"
            default:
                displayText = "Shipping address"
            }
            self.updateAddressTypeButton(text: displayText, addressType: addressType)
        }
        
        // Debug: Log navigation stack before push
        if let navController = navigationController {
            let stackBefore = navController.viewControllers.map { String(describing: type(of: $0)) }.joined(separator: " -> ")
            print("📍 [AddressViewController] Before push MapViewController")
            print("   - Stack count: \(navController.viewControllers.count)")
            print("   - Stack: \(stackBefore)")
            print("   - Current VC: \(String(describing: type(of: self)))")
        }
        
        // Push MapViewController
        navigationController?.pushViewController(mapViewController, animated: true)
        
        // Debug: Log navigation stack after push (with delay to allow push to complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let navController = self?.navigationController {
                let stackAfter = navController.viewControllers.map { String(describing: type(of: $0)) }.joined(separator: " -> ")
                print("📍 [AddressViewController] After push MapViewController")
                print("   - Stack count: \(navController.viewControllers.count)")
                print("   - Stack: \(stackAfter)")
                print("   - Top VC: \(String(describing: type(of: navController.topViewController ?? UIViewController())))")
            }
        }
    }
    
    @objc private func defaultAddressTapped() {
        isCheckboxSelected.toggle()
        updateCheckboxImage()
    }
    
    // MARK: - Location List
    
    private func showLocationList() {
        // Prevent opening multiple times - if card already exists and is visible, just show it
        if let existingCard = cardViewController, existingCard.parent != nil {
            existingCard.show()
            return
        }
        
        // If card exists but is not attached (was dismissed), clean it up first
        if cardViewController != nil {
            cardViewController?.detach()
            cardViewController = nil
        }
        
        // Create Card Configuration for deCommand mode (onDemand)
        // Height: reduced by 100pt from full screen
        let screenHeight = view.bounds.height
        let cardHeight = screenHeight - 100
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
        
        // Attach to current view controller
        cardVC.attach(to: self)
        
        // Store reference
        cardViewController = cardVC
        
        // Create LocationListViewController as content
        let appDIContainer = AppDIContainer()
        let locationListDIContainer = appDIContainer.makeLocationListDIContainer()
        let locationListVC = locationListDIContainer.makeLocationListViewController()
        
        // Setup callback when address is selected
        if let locationListController = locationListVC.controller as? DefaultLocationListController {
            locationListController.onAddressSelected = { [weak self, weak cardVC] address in
                // Fill form with selected address
                self?.contactPersonNameTextField.text = address.contactPersonName
                self?.contactPersonNumberTextField.text = address.contactPersonNumber
                self?.addressSearchTextField.text = address.address
                self?.selectedLatitude = address.latitude
                self?.selectedLongitude = address.longitude
                self?.selectedAddressType = address.addressType
                
                // Update button text based on address type
                let displayText: String
                switch address.addressType {
                case "shipping":
                    displayText = "Shipping address"
                case "shop":
                    displayText = "Shop address"
                case "other":
                    displayText = "Other"
                default:
                    displayText = "Shipping address"
                }
                self?.updateAddressTypeButton(text: displayText, addressType: address.addressType)
                
                // Dismiss card
                cardVC?.dismiss()
                // Clear reference when dismissed
                if cardVC === self?.cardViewController {
                    self?.cardViewController = nil
                }
            }
        }
        
        // Set LocationListViewController as content of CardViewController
        cardVC.setContent(locationListVC)
        
        // Show card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cardVC.show()
        }
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
        
        // Use selectedAddressType from MapViewController, or default to "home" if not set
        let addressType = selectedAddressType.isEmpty ? "home" : selectedAddressType
        
        addressController.didTapSave(
            contactPersonName: contactPersonNameTextField.text ?? "",
            contactPersonNumber: contactPersonNumberTextField.text ?? "",
            address: addressSearchTextField.text ?? "",
            addressType: addressType,
            longitude: selectedLongitude, // Tọa độ từ map selection
            latitude: selectedLatitude, // Tọa độ từ map selection
            isDefault: isCheckboxSelected
        )
    }
}
