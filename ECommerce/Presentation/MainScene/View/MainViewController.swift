//
//  MainViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

/// Main container view controller with sidebar functionality
/// Implements SidebarRevealable protocol for integration with behaviors
final class MainViewController: UIViewController, SidebarRevealable, StoryboardInstantiable {
    
    // MARK: - StoryboardInstantiable
    
    static var storyboardName: String {
        return "Main"
    }
    
    static var storyboardIdentifier: String {
        return "Main"
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var contentContainerView: UIView? // Optional: may not be in storyboard
    
    // MARK: - Properties
    
    private var controller: MainController!
    private var sideMenuViewController: SideMenuViewController!
    private let sideMenuRevealWidth: CGFloat = 260
    
    // Current content view controller
    private var currentContentViewController: UIViewController?
    
    // Callback to set content after view appears
    var onViewDidAppear: (() -> Void)?
    
    // Dependencies
    private var mainCoordinatingController: MainCoordinatingController?
    private var appDIContainer: AppDIContainer?
    private var sideMenuController: SideMenuController?
    
    /// Set coordinating controller (used for dependency injection)
    /// - Parameter coordinatingController: Main coordinating controller
    func setCoordinatingController(_ coordinatingController: MainCoordinatingController) {
        self.mainCoordinatingController = coordinatingController
    }
    
    // Side menu components
    private var animator: SideMenuAnimator!
    private var gestureProcessor: SideMenuPanGestureProcessor!
    private var layoutManager: SideMenuLayoutManager!
    
    // Gesture recognizers
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    
    // MARK: - SidebarRevealable Implementation
    
    @IBAction public func revealSideMenu() {
        toggleSidebar()
    }
    
    func revealSidebar() {
        controller.setSidebarExpanded(true)
    }
    
    func hideSidebar() {
        controller.setSidebarExpanded(false)
    }
    
    func toggleSidebar() {
        controller.toggleSidebar()
    }
    
    // MARK: - Lifecycle
    
    static func create(
        with controller: MainController
    ) -> MainViewController {
        let viewController = MainViewController.instantiateViewController()
        viewController.controller = controller
        return viewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSideMenuComponents()
        setupSideMenu()
        setupGestures()
        bind(to: controller)
        controller.viewDidLoad()
        // Content will be set by AppFlowCoordinator via onViewDidAppear callback
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Call callback if set (used to set content from AppDelegate)
        onViewDidAppear?()
        onViewDidAppear = nil // Clear after first call
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isExpanded = controller.isSidebarExpanded.value
        layoutManager.handleRotation(to: size, isExpanded: isExpanded, coordinator: coordinator)
    }
    
    deinit {
        // Clean up observers
        controller?.isSidebarExpanded.remove(observer: self)
        sideMenuController?.horizontalScrollOffset.remove(observer: self)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func setupSideMenuComponents() {
        // Initialize components
        animator = SideMenuAnimator(revealWidth: sideMenuRevealWidth)
        gestureProcessor = SideMenuPanGestureProcessor(revealWidth: sideMenuRevealWidth)
        layoutManager = SideMenuLayoutManager(revealWidth: sideMenuRevealWidth)
        
        // Setup animator callbacks
        animator.onAnimationComplete = { [weak self] in
            // Animation completed
        }
        
        // Setup gesture processor callbacks
        gestureProcessor.onDragBegan = { [weak self] in
            self?.animator.cancelCurrentAnimation()
        }
        
        gestureProcessor.onDragChanged = { [weak self] progress in
            guard let self = self,
                  let shadowView = self.layoutManager.shadowView else { return }
            self.animator.updateDragProgress(
                sideMenuView: self.sideMenuViewController.view,
                contentView: self.currentContentViewController?.view,
                shadowView: shadowView,
                progress: progress
            )
        }
        
        gestureProcessor.onDragEnded = { [weak self] shouldExpand in
            guard let self = self else { return }
            if shouldExpand {
                self.revealSidebar()
            } else {
                self.hideSidebar()
            }
        }
        
        gestureProcessor.onFastSwipe = { [weak self] swipeRight in
            guard let self = self else { return }
            if swipeRight {
                self.revealSidebar()
            } else {
                self.hideSidebar()
            }
        }
    }
    
    private func setupSideMenu() {
        // Ensure coordinating controller is set (should be set by AppFlowCoordinator)
        guard let coordinatingController = mainCoordinatingController else {
            fatalError("MainCoordinatingController must be set before calling setupSideMenu()")
        }
        
        // Setup side menu coordinating controller
        coordinatingController.setupSideMenuCoordinatingController()
        
        // Get side menu controller to observe horizontal scroll
        sideMenuController = coordinatingController.getSideMenuController()
        
        guard let sideMenuVC = coordinatingController.makeSideMenuViewController() else {
            fatalError("Failed to create SideMenuViewController")
        }
        
        self.sideMenuViewController = sideMenuVC
        
        // Add as child view controller
        addChild(sideMenuViewController)
        view.insertSubview(sideMenuViewController.view, at: 0)
        sideMenuViewController.didMove(toParent: self)
        
        // Setup layout using layout manager
        layoutManager.setupSideMenuLayout(sideMenuView: sideMenuViewController.view, in: view)
        
        // Create shadow view
        let shadowView = UIView()
        layoutManager.setupShadowViewLayout(shadowView: shadowView)
        
        // Observe horizontal scroll offset to reveal sidebar
        observeHorizontalScroll()
    }
    
    /// Set dependencies for MainViewController
    /// - Parameter appDIContainer: App DI Container
    func setDependencies(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
    
    private func setupGestures() {
        // Pan gesture for swipe to reveal/hide on main view (fallback)
        // Primary gesture will be added to content view for better touch handling
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        self.panGestureRecognizer = panGesture
        
        // Tap gesture to dismiss sidebar (will be added to shadow view)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        
        // Add tap gesture to shadow view when it's available
        DispatchQueue.main.async { [weak self] in
            if let shadowView = self?.layoutManager.shadowView {
                shadowView.addGestureRecognizer(tapGesture)
                self?.tapGestureRecognizer = tapGesture
            }
        }
    }
    
    // MARK: - Binding
    
    private func bind(to controller: MainController) {
        // Use weak self to prevent retain cycles
        controller.isSidebarExpanded.observe(on: self) { [weak self] expanded in
            self?.sideMenuState(expanded: expanded)
            self?.gestureProcessor.updateExpandedState(expanded)
        }
    }
    
    /// Observe horizontal scroll offset to reveal sidebar when scrolling horizontally
    private func observeHorizontalScroll() {
        guard let sideMenuController = sideMenuController else { return }
        
        // Observe horizontal scroll offset changes
        sideMenuController.horizontalScrollOffset.observe(on: self) { [weak self] offset in
            self?.handleHorizontalScroll(offset: offset)
        }
    }
    
    /// Handle horizontal scroll offset changes
    /// - Parameter offset: The horizontal scroll offset (positive = scroll right)
    private func handleHorizontalScroll(offset: CGFloat) {
        // Only reveal sidebar if scrolling right (positive offset) and sidebar is not already expanded
        guard offset > 0, !controller.isSidebarExpanded.value else { return }
        
        // Threshold to trigger sidebar reveal (adjust as needed)
        let revealThreshold: CGFloat = 50.0
        
        if offset >= revealThreshold {
            // Reveal sidebar when threshold is reached
            revealSidebar()
        }
    }
    
    /// Update horizontal scroll offset (called by child view controllers)
    /// - Parameter offset: The horizontal scroll offset
    func updateHorizontalScrollOffset(_ offset: CGFloat) {
        sideMenuController?.horizontalScrollOffset.value = offset
    }
    
    // MARK: - Content Management
    
    /// Set content view controller programmatically
    /// - Parameter contentViewController: The view controller to display as content
    func setContentViewController(_ contentViewController: UIViewController) {
        // Remove existing content view controller
        if let currentContent = currentContentViewController {
            removeChildController(currentContent)
        }
        
        // Use contentContainerView if available, otherwise use main view
        let container = (contentContainerView ?? view)!
        
        // Add new content view controller using extension
        add(contentViewController, to: container)
        currentContentViewController = contentViewController
        controller.setContentViewController(contentViewController)
        
        // Setup constraints if using main view
        if contentContainerView == nil {
            // Use frame-based positioning for side-in animation
            contentViewController.view.translatesAutoresizingMaskIntoConstraints = true
            contentViewController.view.frame = view.bounds
            
            // Ensure content view is above side menu (z-order)
            if contentViewController.view.superview == view {
                view.insertSubview(contentViewController.view, at: 1)
            }
            
            // Setup shadow view layout if not already set up
            if layoutManager.shadowView == nil {
                let shadowView = UIView()
                layoutManager.setupShadowViewLayout(shadowView: shadowView)
                
                // Add tap gesture to shadow view
                if let tapGesture = tapGestureRecognizer {
                    shadowView.addGestureRecognizer(tapGesture)
                }
            }
        }
        
        // Add pan gesture to content view to ensure it works
        setupContentPanGesture(for: contentViewController)
    }
    
    /// Setup pan gesture for content view controller
    /// - Parameter contentViewController: Content view controller to add gesture to
    private func setupContentPanGesture(for contentViewController: UIViewController) {
        // Add pan gesture to content view to handle swipe from content area
        // This is the primary gesture recognizer since content view is on top
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        contentViewController.view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Sidebar Animation
    
    /// Update sidebar state (expanded or collapsed)
    /// - Parameter expanded: True to expand, false to collapse
    private func sideMenuState(expanded: Bool) {
        guard let sideMenuView = sideMenuViewController?.view,
              let shadowView = layoutManager.shadowView else { return }
        
        // Update shadow view interaction - only block when expanded
        shadowView.isUserInteractionEnabled = expanded
        
        if expanded {
            animator.animateToExpanded(
                sideMenuView: sideMenuView,
                contentView: currentContentViewController?.view,
                shadowView: shadowView
            )
        } else {
            animator.animateToCollapsed(
                sideMenuView: sideMenuView,
                contentView: currentContentViewController?.view,
                shadowView: shadowView
            )
        }
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        // Debug: Check if gesture is being called
        let translation = sender.translation(in: view)
        let location = sender.location(in: view)
        
        // Always pass to gesture processor
        gestureProcessor.handlePanGesture(sender, in: view)
    }
    
    @objc private func handleTapGesture(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if controller.isSidebarExpanded.value {
                hideSidebar()
            }
        }
    }
}

// MARK: - MainCoordinatingControllerDelegate

extension MainViewController: MainCoordinatingControllerDelegate {
    
    func didSelectMenuItem(at index: Int) {
        handleMenuItemSelection(at: index)
    }
    
    func didSetContentViewController(_ viewController: UIViewController) {
        setContentViewController(viewController)
    }
    
    // MARK: - Private
    
    private func handleMenuItemSelection(at index: Int) {
        switch index {
        case 0:
            // Home - Navigate to ProductsViewController (default content)
            // ProductsViewController is already set as content by AppFlowCoordinator
            break
        case 1:
            // Products - already showing, just hide sidebar
            break
        case 2:
            // Cart - TODO: Navigate to cart
            break
        case 3:
            // Profile - TODO: Navigate to profile
            break
        case 4:
            // Settings - TODO: Navigate to settings
            break
        default:
            break
        }
        
        // Collapse side menu with animation
        DispatchQueue.main.async { [weak self] in
            self?.hideSidebar()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan gesture to work simultaneously with scroll gestures
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Allow gesture to receive touches
        return true
    }
}

