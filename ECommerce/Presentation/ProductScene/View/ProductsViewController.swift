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
        super.viewDidLoad()
        setupViews()
        bindProductsSpecific()
        setupChildViewController()
        setupSidebarGesture()
        setupCardButton()
        // viewDidLoad will be called on mediatingController by ProductsTableViewController
    }
    
    // MARK: - Common Binding Override
    
    override func bindCommon() {
        super.bindCommon()
        bindProductsSpecific()
    }
    
    // MARK: - Products-Specific Binding
    
    private func bindProductsSpecific() {
        productsController.items.observe(on: self) { [weak self] _ in
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
        
        // Setup constraints with top padding equal to navbar height
        NSLayoutConstraint.activate([
            tableViewController.view.topAnchor.constraint(equalTo: productsListContainer.topAnchor, constant: navBarHeight),
            tableViewController.view.leadingAnchor.constraint(equalTo: productsListContainer.leadingAnchor),
            tableViewController.view.trailingAnchor.constraint(equalTo: productsListContainer.trailingAnchor),
            tableViewController.view.bottomAnchor.constraint(equalTo: productsListContainer.bottomAnchor)
        ])
        
        tableViewController.didMove(toParent: self)
        productsTableViewController = tableViewController
        
        // Bind tableView with navigation bar for scroll behavior
        if let tableView = tableViewController.tableView {
            bindNavigationBar(to: tableView)
        }
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
        }
    }
    
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
    
    deinit {
        print("🔵 [ProductsViewController] deinit called")
        // Cleanup card view controller when ProductsViewController is deallocated
        cardViewController?.detach()
        cardViewController = nil
    }
}
