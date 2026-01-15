//
//  ProductDetailViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import UIKit

final class ProductDetailViewController: EcoViewController {
    
    private var productDetailController: ProductDetailController! {
        get { controller as? ProductDetailController }
    }
    
    private var collectionViewController: ProductDetailCollectionViewController?
    private var orderActionView: OrderActionView!
    private var cardViewController: CardViewController?
    
    // Quantity từ ProductInfoCell
    private var itemQuantity: Int = 1
    
    // OrderUseCase và Cancellable
    private var orderUseCase: OrderUseCase?
    private var placeOrderTask: Cancellable? { willSet { placeOrderTask?.cancel() } }
    private var placedOrder: Order?
    
    // Utilities for location cache
    private let utilities = Utilities()
    
    // MARK: - Lifecycle
    
    static func create(
        with productDetailController: ProductDetailController
    ) -> ProductDetailViewController {
        print("🔵 [ProductDetailViewController] create called")
        let view = ProductDetailViewController.instantiateViewController()
        view.controller = productDetailController
        print("   ✅ ProductDetailViewController instance created")
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 [ProductDetailViewController] viewDidLoad called")
        setupViews()
        setupChildViewController()
        setupOrderActionView()
        setupBackNavigation()
        setupOrderUseCase()
        
        // ✅ QUAN TRỌNG: Gọi onViewDidLoad để trigger navigation state setup
        productDetailController.onViewDidLoad()
        
        print("   ✅ ProductDetailViewController setup completed")
    }
    
    // MARK: - Setup
    
    private func setupBackNavigation() {
        // Setup back button callback
        if let defaultProductDetailController = productDetailController as? DefaultProductDetailController {
            defaultProductDetailController.onBack = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
    }
    
    private func setupChildViewController() {
        let collectionVC = ProductDetailCollectionViewController.instantiateViewController()
        collectionVC.productDetailController = productDetailController
        
        // Setup callback để nhận quantity changes
        collectionVC.onQuantityChanged = { [weak self] quantity in
            self?.itemQuantity = quantity
            self?.updateOrderActionView()
        }
        
        addChild(collectionVC)
        view.addSubview(collectionVC.view)
        collectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            collectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100) // Reserve space for button
        ])
        
        collectionVC.didMove(toParent: self)
        collectionViewController = collectionVC
        
        // Bind collection view scroll with navigation bar
        if let collectionView = collectionVC.collectionView {
            bindNavigationBar(to: collectionView)
        }
        
        // ✅ QUAN TRỌNG: Đảm bảo navigation bar nằm trên cùng của layer UI
        // Cần gọi sau khi đã add child view controller
        if let navBarView = navigationBarViewController?.view {
            view.bringSubviewToFront(navBarView)
            navBarView.isUserInteractionEnabled = true
            print("✅ [ProductDetailViewController] Navigation bar brought to front")
        }
    }
    
    private func setupOrderUseCase() {
        let appDIContainer = AppDIContainer()
        let orderDIContainer = appDIContainer.makeOrderDIContainer()
        orderUseCase = orderDIContainer.makeOrderUseCase()
    }
    
    private func setupOrderActionView() {
        orderActionView = OrderActionView()
        orderActionView.delegate = self
        orderActionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orderActionView)
        
        NSLayoutConstraint.activate([
            orderActionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orderActionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orderActionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            orderActionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80 + 24) // Tăng thêm 24pt
        ])
        
        // Configure OrderActionView
        orderActionView.topLeftLabelText = "Subtotal"
        orderActionView.buttonTitle = "Start order"
        orderActionView.buttonCornerRadius = BorderRadius.tokenBorderRadius16
        orderActionView.leftItemType = .icon(UIImage(systemName: "plus.circle")) // Thêm icon add to card
        
        // Update initial values
        updateOrderActionView()
        
        // Ensure z-order: Navigation bar > OrderActionView > Collection view
        // OrderActionView should be below navbar but above collection view
        view.bringSubviewToFront(orderActionView)
    }
    
    private func updateOrderActionView() {
        guard let product = productDetailController.product.value else { return }
        
        let priceNumber = product.price.convertMoneyToNumber()
        let totalPrice = priceNumber * Double(itemQuantity)
        
        // Format totalPrice to currency string
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.maximumFractionDigits = 0
        
        let formattedPrice = numberFormatter.string(from: NSNumber(value: totalPrice)) ?? "0"
        
        orderActionView.topRightLabelText = "$ \(formattedPrice) ⋀"
    }
    
    private func formatDoubleToCurrency(_ value: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func openAddToCardOrderCard() {
        guard let product = productDetailController.product.value else {
            print("⚠️ [ProductDetailViewController] Product is nil, cannot open add to card")
            return
        }
        
        print("🔵 [ProductDetailViewController] openAddToCardOrderCard called")
        print("   📦 Product ID: \(product.id)")
        
        // Create Card Configuration - cách top 200pt
        let screenHeight = view.bounds.height
        let topPadding: CGFloat = 200
        let cardConfig = CardConfiguration(
            expandedHeight: screenHeight - topPadding,
            collapsedHeight: screenHeight - topPadding,
            presentationMode: .onDemand,
            enableGesture: true
        )
        
        // Create Card Controller
        let cardController = DefaultCardController(configuration: cardConfig)
        
        // Create Card View Controller
        let cardVC = CardViewController.create(with: cardController)
        
        // Attach to current view controller
        cardVC.attach(to: self)
        
        // Create OrderViewController with cart items
        let cartItems = [CartItem(id: product.id, quantity: itemQuantity)]
        let appDIContainer = AppDIContainer()
        let orderDIContainer = appDIContainer.makeOrderDIContainer()
        let orderVC = orderDIContainer.makeOrderViewController(cartItems: cartItems, product: product, isAddToCardMode: true)
        
        // Set OrderViewController as content
        cardVC.setContent(orderVC)
        
        // Store reference
        cardViewController = cardVC
        
        // Ensure view is laid out and parent view height is set before showing
        view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak cardVC, weak self] in
            guard let cardVC = cardVC, let self = self else { return }
            let height = self.view.bounds.height
            if height > 0 {
                cardVC.updateParentViewHeightIfNeeded()
                cardVC.show()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cardVC.updateParentViewHeightIfNeeded()
                    cardVC.show()
                }
            }
        }
    }
    
    private func openOrderCard() {
        guard let product = productDetailController.product.value else {
            print("⚠️ [ProductDetailViewController] Product is nil, cannot open order")
            return
        }
        
        print("🔵 [ProductDetailViewController] openOrderCard called")
        print("   📦 Product ID: \(product.id)")
        
        // Check if card already exists and is still attached
        if let existingCard = cardViewController, existingCard.parent != nil {
            print("🔵 [ProductDetailViewController] Card already exists, showing it")
            existingCard.show()
            return
        }
        
        // If card exists but is not attached (was dismissed), clean it up first
        if cardViewController != nil {
            print("🔵 [ProductDetailViewController] Card exists but not attached, cleaning up")
            cardViewController?.detach()
            cardViewController = nil
        }
        
        print("🔵 [ProductDetailViewController] Creating new card")
        
        // Create Card Configuration - cách top 180pt
        let screenHeight = view.bounds.height
        let topPadding: CGFloat = 180
        let cardConfig = CardConfiguration(
            expandedHeight: screenHeight - topPadding,
            collapsedHeight: screenHeight - topPadding,
            presentationMode: .onDemand,
            enableGesture: true
        )
        
        // Create Card Controller
        let cardController = DefaultCardController(configuration: cardConfig)
        
        // Create Card View Controller
        let cardVC = CardViewController.create(with: cardController)
        
        // Attach to current view controller
        cardVC.attach(to: self)
        
        // Create OrderViewController with cart items
        let cartItems = [CartItem(id: product.id, quantity: itemQuantity)]
        let appDIContainer = AppDIContainer()
        let orderDIContainer = appDIContainer.makeOrderDIContainer()
        let orderVC = orderDIContainer.makeOrderViewController(cartItems: cartItems, product: product)
        
        // Set OrderViewController as content
        cardVC.setContent(orderVC)
        
        // Store reference
        cardViewController = cardVC
        
        // Ensure view is laid out and parent view height is set before showing
        view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak cardVC, weak self] in
            guard let cardVC = cardVC, let self = self else { return }
            let height = self.view.bounds.height
            print("🔵 [ProductDetailViewController] Async block - view.bounds.height: \(height)")
            if height > 0 {
                cardVC.updateParentViewHeightIfNeeded()
                print("🔵 [ProductDetailViewController] Calling show()")
                cardVC.show()
            } else {
                print("⚠️ [ProductDetailViewController] Height is 0, waiting...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cardVC.updateParentViewHeightIfNeeded()
                    cardVC.show()
                }
            }
        }
    }
    
    private func placeOrder() {
        guard let product = productDetailController.product.value else { return }
        guard let orderUseCase = orderUseCase else { return }
        
        // Get cached address
        let address = utilities.getCachedAddress() ?? ""
        
        // Create cart items
        let cartItems = [CartItem(id: product.id, quantity: itemQuantity)]
        
        // Set loading state
        orderActionView.isLoading = true
        
        // Place order
        // TODO: Get address details from user's saved addresses if available
        placeOrderTask = orderUseCase.placeOrder(
            cart: cartItems,
            orderNote: nil,
            deliveryAddressId: nil,
            addressDetail: address,
            countryId: nil,
            provinceId: nil,
            districtId: nil,
            wardId: nil,
            contactPersonName: "", // TODO: Get from user profile
            contactPersonNumber: "" // TODO: Get from user profile
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.orderActionView.isLoading = false
                
                switch result {
                case .success(let order):
                    self.placedOrder = order
                    print("✅ [ProductDetailViewController] Order placed successfully: \(order.orderId)")
                    // Open order card after successful placement
                    self.openOrderCard()
                case .failure(let error):
                    print("❌ [ProductDetailViewController] Order placement failed: \(error)")
                    // TODO: Show error alert
                }
            }
        }
    }
    
    private func showPricingCalculationPopup() {
        guard let product = productDetailController.product.value else { return }
        
        let priceNumber = product.price.convertMoneyToNumber()
        let totalPrice = priceNumber * Double(itemQuantity)
        
        let popup = PricingCaculationPopup(frame: .zero)
        popup.subTotalValue.text = formatDoubleToCurrency(totalPrice) + CoreUtilsKitLocalization.currency_unit.localized
        popup.orderBreakdownValueLabel.text = formatDoubleToCurrency(totalPrice) + CoreUtilsKitLocalization.currency_unit.localized
        popup.shippingValueLabel.text = "0" + CoreUtilsKitLocalization.currency_unit.localized
        
        popup.show(in: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ✅ QUAN TRỌNG: Đảm bảo z-order đúng: Navigation bar > OrderActionView > Collection view
        // Navigation bar ở trên cùng
        if let navBarView = navigationBarViewController?.view {
            view.bringSubviewToFront(navBarView)
            navBarView.isUserInteractionEnabled = true
        }
        
        // OrderActionView ở dưới navbar nhưng trên collection view
        view.bringSubviewToFront(orderActionView)
    }
}

// MARK: - OrderActionViewDelegate

extension ProductDetailViewController: OrderActionViewDelegate {
    
    func orderActionViewDidTapAction(_ view: OrderActionView) {
        // When "Start order" button is tapped, push CheckoutViewController
        pushCheckoutViewController()
    }
    
    func orderActionViewDidTapLeftItem(_ view: OrderActionView) {
        // When left icon (add to card) is tapped, open CardView with OrderViewController
        openAddToCardOrderCard()
    }
    
    func orderActionViewDidTapTopRightLabel(_ view: OrderActionView) {
        showPricingCalculationPopup()
    }
    
    private func pushCheckoutViewController() {
        // Get productDetailModel từ controller
        guard let productDetailModel = productDetailController.product.value else {
            print("⚠️ [ProductDetailViewController] Product is nil, cannot push checkout")
            return
        }
        
        // Find navigation controller
        guard let navigationController = self.navigationController else {
            print("⚠️ [ProductDetailViewController] No navigation controller found")
            return
        }
        
        // Create cart items from product
        let cartItems = [CartItem(id: productDetailModel.id, quantity: itemQuantity)]
        
        // Use CheckoutSceneDIContainer to create CheckoutViewController with proper controller injection
        let appDIContainer = AppDIContainer()
        let checkoutSceneDIContainer = appDIContainer.makeCheckoutSceneDIContainer()
        let checkoutVC = checkoutSceneDIContainer.makeCheckoutViewController(cartItems: cartItems, product: productDetailModel)
        
        navigationController.pushViewController(checkoutVC, animated: true)
    }
}
