//
//  ProductsViewController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductsViewController: EcoViewController {
    
    @IBOutlet private var productsListContainer: UIView!
    @IBOutlet private var emptyDataLabel: UILabel!
    
    @IBOutlet weak var productListConstraint: NSLayoutConstraint!
    
    private var productsController: ProductsController! {
        get { controller as? ProductsController }
    }
    private var productsTableViewController: ProductsTableViewController?
    
    // Card View Controller
    private var cardViewController: CardViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with productsController: ProductsController
    ) -> ProductsViewController {
        let view = ProductsViewController.instantiateViewController()
        // Inject controller for EcoViewController
        view.controller = productsController
        return view
    }
    
    override func viewDidLoad() {
        print("🟢 [ProductsViewController] viewDidLoad - Starting initialization")
        // Setup callbacks TRƯỚC super.viewDidLoad() để đảm bảo callback được setup trước khi navigation bar được setup
        setupCardButton()
        setupProductSelection()
        
        super.viewDidLoad()
        setupViews()
        bindProductsSpecific()
        setupChildViewController()
        setupSidebarGesture()
        print("✅ [ProductsViewController] viewDidLoad - Initialization completed")
        // viewDidLoad will be called on mediatingController by ProductsTableViewController
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindProductsSpecific()
    }
    
    // MARK: - Products-Specific Binding
    
    private func bindProductsSpecific() {
        productsController.items.observe(on: self) { [weak self] items in
            print("📦 [ProductsViewController] Items updated - Count: \(items.count)")
            self?.updateItems()
        }
    }
    
    // MARK: - Loading Handler Override
    
    override func handleLoading(_ isLoading: Bool) {
        super.handleLoading(isLoading)
        
        emptyDataLabel.isHidden = true
        productsListContainer.isHidden = true
        
        if !isLoading {
            productsListContainer.isHidden = productsController.isEmpty
            emptyDataLabel.isHidden = !productsController.isEmpty
        }
        
        productsTableViewController?.updateLoading(isLoading)
    }
    
    // MARK: - Error Handler Override
    
    override func handleError(_ error: Error?) {
        guard let error else { return }
        showAlert(title: productsController.errorTitle, message: error.localizedDescription)
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
        
        // Add as child view controller
        addChild(tableViewController)
        productsListContainer.addSubview(tableViewController.view)
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Get navigation bar height for top padding
        let navBarHeight = productsController.navigationBarInitialHeight
        let navBarCollap = self.productsController.navigationBarCollapsedHeight
        
        self.productListConstraint.constant = navBarHeight
        
        // Setup constraints with top padding equal to navbar height
//        NSLayoutConstraint.activate([
//            tableViewController.view.topAnchor.constraint(equalTo: productsListContainer.topAnchor, constant: navBarHeight),
//            tableViewController.view.leadingAnchor.constraint(equalTo: productsListContainer.leadingAnchor),
//            tableViewController.view.trailingAnchor.constraint(equalTo: productsListContainer.trailingAnchor),
//            tableViewController.view.bottomAnchor.constraint(equalTo: productsListContainer.bottomAnchor)
//        ])
        
        tableViewController.didMove(toParent: self)
        productsTableViewController = tableViewController
        
        // ✅ QUAN TRỌNG: Set delegate để ProductsViewController xử lý didSelectRowAt trực tiếp
        // Điều này tránh gesture conflicts và cho phép view cha xử lý navigation
        if let tableView = tableViewController.tableView {
            tableView.delegate = self
            bindNavigationBar(to: tableView)
            // Bind scroll để thay đổi alpha của tabBar
            bindTabBarScroll(to: tableView)
        }
    }
    
    /// Bind scroll để thay đổi alpha của tabBar khi scroll
    private func bindTabBarScroll(to scrollView: UIScrollView) {
        // TabBar alpha sẽ được update trong scrollViewDidScroll override
        // Store reference để sử dụng sau
    }
    
    // Track previous scroll offset để detect scroll direction
    private var previousScrollOffset: CGFloat = 0
    
    /// Khôi phục TabBar appearance ban đầu (không trong suốt)
    private func restoreTabBarAppearance(tabBar: UITabBar) {
        UIView.animate(withDuration: 0.2) {
            if #available(iOS 13.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor.black
                ]
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.gray
                ]
                tabBar.standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    tabBar.scrollEdgeAppearance = appearance
                }
            } else {
                tabBar.barTintColor = UIColor.white
                tabBar.isTranslucent = false
            }
        }
    }
    
    /// Reference đến TabBar để update alpha
    private var tabBarReference: UITabBar? {
        return findTabBarController()?.tabBar
    }
    
    /// Find TabBarController từ parent hierarchy
    private func findTabBarController() -> UITabBarController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let tabBarController = responder as? UITabBarController {
                return tabBarController
            }
        }
        return nil
    }
    
    private func updateItems() {
        productsTableViewController?.reload()
    }
    
    // MARK: - Card Setup
    
    private func setupCardButton() {
        // Setup callback for card button tap - cast to implementation type to set callback
        if let defaultProductsController = productsController as? DefaultProductsController {
            defaultProductsController.onOpenCard = { [weak self] in
                self?.openCardViewController()
            }
            // Setup callback for camera button tap
            defaultProductsController.onOpenCamera = { [weak self] in
                print("📷 [ProductsViewController] onOpenCamera callback triggered")
                self?.openAISearchCamera()
            }
            // Setup callback for back button tap (khi được push từ màn khác)
            defaultProductsController.onBack = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            print("✅ [ProductsViewController] Camera callback setup completed")
        } else {
            print("⚠️ [ProductsViewController] productsController is not DefaultProductsController")
        }
    }
    
    // Flag để tránh dismiss nhiều lần
    private var isDismissingCamera = false
    // Flag để tránh present camera nhiều lần
    private var isPresentingCamera = false
    
    private func openAISearchCamera() {
        print("📷 [ProductsViewController] Opening AI Search camera")
        
        // Kiểm tra xem đã có camera đang được present chưa
        if presentedViewController != nil {
            print("⚠️ [ProductsViewController] Camera already presented, skipping")
            return
        }
        
        // Kiểm tra flag để tránh present nhiều lần
        guard !isPresentingCamera else {
            print("⚠️ [ProductsViewController] Camera is already being presented, skipping")
            return
        }
        
        isPresentingCamera = true
        // Reset flag
        isDismissingCamera = false
        
        // Mở camera với chế độ .aiSearch
        presentAISearchCamera(
            onImageCaptured: { [weak self] image in
                print("📷 [ProductsViewController] Image captured from AI Search camera - size: \(image.size)")
                // Image captured - labels will be handled separately
            },
            onLabelsDetected: { [weak self] labels in
                print("🔍 [ProductsViewController] Labels detected from AI Search: \(labels.count) labels")
                guard let self = self else { return }
                
                // Tránh dismiss nhiều lần
                guard !self.isDismissingCamera else {
                    print("⚠️ [ProductsViewController] Already dismissing camera, skipping")
                    return
                }
                
                self.isDismissingCamera = true
                
                // Filter items trước, sau đó mới dismiss camera
                print("🔍 [ProductsViewController] Filtering items first...")
                self.handleAISearchLabels(labels)
                
                // Đợi một chút để đảm bảo filter đã hoàn thành, sau đó dismiss camera
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    guard let self = self else { return }
                    
                    // Dismiss camera sau khi filter xong
                    if let presentedVC = self.presentedViewController {
                        print("📷 [ProductsViewController] Dismissing camera after filter completed...")
                        presentedVC.dismiss(animated: true) {
                            print("📷 [ProductsViewController] Camera dismissed after filter completed")
                            self.isDismissingCamera = false
                        }
                    } else {
                        print("⚠️ [ProductsViewController] No presented VC found")
                        self.isDismissingCamera = false
                    }
                }
            },
            onDismiss: { [weak self] in
                print("📷 [ProductsViewController] AI Search camera dismissed")
                // Reset flag khi camera dismissed
                self?.isPresentingCamera = false
            }
        )
        
        // Reset flag sau một khoảng thời gian để tránh stuck
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPresentingCamera = false
        }
    }
    
    private func handleAISearchLabels(_ labels: [(String, Double)]) {
        print("🔍 [ProductsViewController] Handling AI Search labels - filtering items")
        // Filter items dựa trên labels từ camera model
        if let defaultProductsController = productsController as? DefaultProductsController {
            defaultProductsController.filterItemsByLabels(labels)
            
            // Reload tableView sau khi filter
            DispatchQueue.main.async { [weak self] in
                self?.productsTableViewController?.reload()
                print("✅ [ProductsViewController] TableView reloaded after AI Search filter")
            }
        } else {
            print("⚠️ [ProductsViewController] productsController is not DefaultProductsController")
        }
    }
    
    private func setupProductSelection() {
        print("🔵 [ProductsViewController] setupProductSelection called")
        // Setup callback for product item selection
        if let defaultProductsController = productsController as? DefaultProductsController {
            print("   ✅ Found DefaultProductsController, setting up onSelectProductItem callback")
            defaultProductsController.onSelectProductItem = { [weak self] productItem in
                print("   🔔 [ProductsViewController] onSelectProductItem callback triggered")
                print("      📦 Product: \(productItem.name) (ID: \(productItem.id))")
                self?.navigateToProductDetail(productItem: productItem)
            }
            print("   ✅ onSelectProductItem callback set successfully")
        } else {
            print("   ⚠️ productsController is not DefaultProductsController, cannot set callback")
        }
    }
    
    private func navigateToProductDetail(productItem: ProductItemModel) {
        print("🔵 [ProductsViewController] navigateToProductDetail called")
        print("   📦 Product: \(productItem.name) (ID: \(productItem.id))")
        print("   🔍 Searching for navigation controller...")
        
        // Try to get navigation controller from different sources
        var navController: UINavigationController?
        
        // Method 1: Direct navigationController property
        print("   📍 Method 1: Checking self.navigationController...")
        navController = navigationController
        if navController != nil {
            print("   ✅ Found navigationController via Method 1")
        } else {
            print("   ❌ Method 1: navigationController is nil")
        }
        
        // Method 2: Find ContentViewController (parent of SegmentedPageContainer) and get its navigation controller
        if navController == nil {
            print("   📍 Method 2: Searching for ContentViewController in parent hierarchy...")
            // Find ContentViewController in parent hierarchy
            var currentVC: UIViewController? = self
            var depth = 0
            while currentVC != nil && depth < 10 {
                if let contentVC = currentVC as? ContentViewController {
                    navController = contentVC.navigationController
                    print("   ✅ Found ContentViewController at depth \(depth), navController: \(String(describing: navController))")
                    break
                }
                print("      Depth \(depth): \(type(of: currentVC!))")
                currentVC = currentVC?.parent ?? currentVC?.presentingViewController
                depth += 1
            }
            if navController == nil {
                print("   ❌ Method 2: ContentViewController not found")
            }
        }
        
        // Method 3: Find parent navigation controller
        if navController == nil {
            print("   📍 Method 3: Using findParentViewController()...")
            if let parentVC = findParentViewController() {
                navController = parentVC.navigationController
                if navController != nil {
                    print("   ✅ Found navigationController via Method 3")
                } else {
                    print("   ❌ Method 3: parentVC.navigationController is nil")
                }
            } else {
                print("   ❌ Method 3: findParentViewController() returned nil")
            }
        }
        
        // Method 4: Find from parent view controller hierarchy
        if navController == nil {
            print("   📍 Method 4: Searching parent hierarchy...")
            var parentVC = parent
            var depth = 0
            while parentVC != nil && depth < 10 {
                if let nav = parentVC?.navigationController {
                    navController = nav
                    print("   ✅ Found navigationController via Method 4 at depth \(depth)")
                    break
                }
                print("      Depth \(depth): \(type(of: parentVC!))")
                parentVC = parentVC?.parent
                depth += 1
            }
            if navController == nil {
                print("   ❌ Method 4: No navigationController found in parent hierarchy")
            }
        }
        
        // Method 5: Find TabBarController and get selected navigation controller
        if navController == nil {
            print("   📍 Method 5: Searching for TabBarController...")
            if let tabBarController: UITabBarController = findParentViewController() {
                if let selectedNav = tabBarController.selectedViewController as? UINavigationController {
                    navController = selectedNav
                    print("   ✅ Found TabBarController, using selected navController")
                } else {
                    print("   ❌ Method 5: selectedViewController is not UINavigationController")
                }
            } else {
                print("   ❌ Method 5: TabBarController not found")
            }
        }
        
        guard let navigationController = navController else {
            print("   ⚠️ [ProductsViewController] No navigation controller found after all methods.")
            print("   - self.navigationController: \(String(describing: self.navigationController))")
            print("   - parent: \(String(describing: parent))")
            print("   - parent?.navigationController: \(String(describing: parent?.navigationController))")
            return
        }
        
        print("   ✅ Navigation controller found: \(type(of: navigationController))")
        print("   🔧 Creating ProductDetailDIContainer...")
        
        // Create ProductDetailDIContainer and CoordinatingController
        let appDIContainer = AppDIContainer()
        let productDetailDIContainer = appDIContainer.makeProductDetailDIContainer()
        print("   ✅ ProductDetailDIContainer created")
        
        print("   🔧 Creating ProductDetailCoordinatingController...")
        let productDetailCoordinatingController = productDetailDIContainer.makeProductDetailCoordinatingController(
            navigationController: navigationController
        )
        print("   ✅ ProductDetailCoordinatingController created")
        
        print("   🚀 Calling coordinatingController.start(productItem:)...")
        // Navigate to ProductDetail
        productDetailCoordinatingController.start(productItem: productItem)
        print("   ✅ coordinatingController.start() completed")
    }
}

// MARK: - UITableViewDelegate

extension ProductsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("🔵 [ProductsViewController] didSelectRowAt called - index: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        // ✅ QUAN TRỌNG: Xử lý push trực tiếp từ view cha
        // Điều này tránh gesture conflicts và cho phép navigation hoạt động ngay
        guard indexPath.row >= 0, indexPath.row < productsController.items.value.count else {
            print("⚠️ [ProductsViewController] Invalid index: \(indexPath.row)")
            return
        }
        
        let productItem = productsController.items.value[indexPath.row]
        print("   📦 Product item: \(productItem.name) (ID: \(productItem.id))")
        print("   🚀 Navigating to ProductDetail directly from ProductsViewController...")
        
        navigateToProductDetail(productItem: productItem)
    }
}

// MARK: - UIScrollViewDelegate Override

extension ProductsViewController {
    
    // Override scrollViewDidScroll từ EcoBaseViewController để thêm logic cho tabBar alpha
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Gọi super để xử lý navigation bar scroll
        super.scrollViewDidScroll(scrollView)
        
        // Update productListConstraint based on scroll progress
        updateProductListConstraint(for: scrollView)
        
        // Update tabBar alpha dựa trên scroll direction
        let currentOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 50 // Ngưỡng để bắt đầu thay đổi alpha
        
        if let tabBar = tabBarReference {
            // Detect scroll direction
            let isScrollingDown = currentOffset > previousScrollOffset
            let isScrollingUp = currentOffset < previousScrollOffset
            
            if currentOffset > threshold {
                if isScrollingDown {
                    // Scroll xuống: Làm TabBar trong suốt để nhìn thấy nội dung phía sau
                    UIView.animate(withDuration: 0.2) {
                        if #available(iOS 13.0, *) {
                            // Tạo appearance mới với transparent background
                            let appearance = UITabBarAppearance()
                            appearance.configureWithTransparentBackground()
                            appearance.backgroundColor = UIColor.white.withAlphaComponent(0.6)
                            
                            // Giữ nguyên icon và text colors
                            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
                            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                                .foregroundColor: UIColor.black
                            ]
                            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                                .foregroundColor: UIColor.gray
                            ]
                            
                            tabBar.standardAppearance = appearance
                            if #available(iOS 15.0, *) {
                                tabBar.scrollEdgeAppearance = appearance
                            }
                        } else {
                            // iOS 12 và trước: set barTintColor với alpha
                            tabBar.barTintColor = UIColor.white.withAlphaComponent(0.6)
                            tabBar.isTranslucent = true
                        }
                    }
                } else if isScrollingUp {
                    // Scroll lên: Khôi phục TabBar không trong suốt
                    restoreTabBarAppearance(tabBar: tabBar)
                }
            } else {
                // Ở đầu trang: Khôi phục TabBar không trong suốt
                restoreTabBarAppearance(tabBar: tabBar)
            }
        }
        
        // Update previous offset
        previousScrollOffset = currentOffset
    }
    
    /// Update productListConstraint based on scroll progress
    /// Constraint sẽ giảm từ navBarHeight xuống navBarCollapsedHeight khi scroll
    private func updateProductListConstraint(for scrollView: UIScrollView) {
        guard let productsController = productsController else { return }
        
        let navBarHeight = productsController.navigationBarInitialHeight
        let navBarCollapsed = productsController.navigationBarCollapsedHeight
        
        // Tính progress tương tự như trong EcoNavigationBarView.handleCollapseWithSearch
        let threshold: CGFloat = 50
        let maxOffset: CGFloat = 100
        let currentOffset = scrollView.contentOffset.y
        let progress = min(max((currentOffset - threshold) / (maxOffset - threshold), 0), 1)
        
        // Tính target constant: từ navBarHeight giảm dần xuống navBarCollapsed
        let heightDifference = navBarHeight - navBarCollapsed
        let targetConstant = navBarHeight - (heightDifference * progress)
        
        // Update constraint với animation mượt
        if abs(productListConstraint.constant - targetConstant) > 0.1 {
            productListConstraint.constant = targetConstant
            view.layoutIfNeeded()
        }
    }
}

extension ProductsViewController {
    
    private func openCardViewController() {
        print("🔵 [ProductsViewController] openCardViewController called")
        
        // Check if card already exists and is still attached
        if let existingCard = cardViewController, existingCard.parent != nil {
            print("🔵 [ProductsViewController] Card already exists, showing it")
            existingCard.show()
            return
        }
        
        // If card exists but is not attached (was dismissed), clean it up first
        if cardViewController != nil {
            print("🔵 [ProductsViewController] Card exists but not attached, cleaning up")
            cardViewController?.detach()
            cardViewController = nil
        }
        
        print("🔵 [ProductsViewController] Creating new card")
        
        // Create Card Configuration
        // Expanded height: cách đỉnh 80pt (phủ gần đầy màn hình)
        // Collapsed height: không dùng vì chỉ có expanded và hidden
        let screenHeight = view.bounds.height
        let topPadding: CGFloat = 12
        let cardConfig = CardConfiguration(
            expandedHeight: screenHeight - topPadding,
            collapsedHeight: screenHeight - topPadding, // Same as expanded for full-screen-like behavior
            presentationMode: .onDemand,
            enableGesture: true
        )
        
        // Create Card Controller
        let cardController = DefaultCardController(configuration: cardConfig)
        
        // Create Card View Controller
        let cardVC = CardViewController.create(with: cardController)
        
        // Attach to current view controller
        cardVC.attach(to: self)
        print("🔵 [ProductsViewController] Card attached, view.bounds.height: \(view.bounds.height)")
        
        // Create and set SignUpViewController as content
        setupSignUpContent(for: cardVC)
        
        // Store reference
        cardViewController = cardVC
        
        // Ensure view is laid out and parent view height is set before showing
        // Wait for next run loop to ensure view hierarchy is ready
        view.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak cardVC, weak self] in
            guard let cardVC = cardVC, let self = self else { return }
            // Update parent view height to ensure it's correct (view bounds should be ready now)
            let height = self.view.bounds.height
            print("🔵 [ProductsViewController] Async block - view.bounds.height: \(height)")
            if height > 0 {
                cardVC.updateParentViewHeightIfNeeded()
                print("🔵 [ProductsViewController] Calling show()")
                // Now show the card - this will animate from hidden to collapsed
                cardVC.show()
            } else {
                // If height is still 0, wait a bit more
                print("⚠️ [ProductsViewController] Height is 0, waiting...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cardVC.updateParentViewHeightIfNeeded()
                    cardVC.show()
                }
            }
        }
    }
    
    private func setupSignUpContent(for cardVC: CardViewController) {
        // Create AuthSceneDIContainer to get SignUpViewController
        let appDIContainer = AppDIContainer()
        let authSceneDIContainer = appDIContainer.makeAuthSceneDIContainer()
        
        // Create SignUpController and SignUpViewController
        let signUpController = authSceneDIContainer.makeSignUpController()
        let signUpVC = authSceneDIContainer.makeSignUpViewController()
        
        // Set SignUpViewController as content of CardViewController
        cardVC.setContent(signUpVC)
        
        // Setup callback for dismiss - cleanup when card is dismissed
        if let defaultCardController = cardVC.controller as? DefaultCardController {
            defaultCardController.onDismissed = { [weak self, weak cardVC] in
                print("🔵 [ProductsViewController] Card dismissed - checking if should cleanup")
                // Option 1: Keep card for reuse (current behavior)
                // Card stays in memory, can be shown again quickly
                // deinit will only be called when ProductsViewController is deallocated
                
                // Option 2: Auto-cleanup on dismiss (uncomment to enable)
                // This will fully remove the card, requiring recreation on next show
                // guard let self = self, let cardVC = cardVC else { return }
                // cardVC.detach()
                // self.cardViewController = nil
                // print("🔵 [ProductsViewController] Card fully cleaned up - deinit should be called")
            }
        }
    }
    
//    deinit {
//        print("🔵 [ProductsViewController] deinit called")
//        // Cleanup card view controller when ProductsViewController is deallocated
//        cardViewController?.detach()
//        cardViewController = nil
//    }
}
