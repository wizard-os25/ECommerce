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
    
    private var mediatingController: MainMediatingController!
    private var sideMenuViewController: SideMenuViewController!
    private let sideMenuRevealWidth: CGFloat = 260
    
    // Current content view controller
    private var currentContentViewController: UIViewController?
    
    // Callback to set content after view appears
    var onViewDidAppear: (() -> Void)?
    
    // Dependencies
    private var mainCoordinatingController: MainCoordinatingController?
    private var appDIContainer: AppDIContainer?
    
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
        mediatingController.setSidebarExpanded(true)
    }
    
    func hideSidebar() {
        mediatingController.setSidebarExpanded(false)
    }
    
    func toggleSidebar() {
        mediatingController.toggleSidebar()
    }
    
    // MARK: - Lifecycle
    
    static func create(
        with mediatingController: MainMediatingController
    ) -> MainViewController {
        let viewController = MainViewController.instantiateViewController()
        viewController.mediatingController = mediatingController
        return viewController
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSideMenuComponents()
        setupSideMenu()
        setupGestures()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
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
        let isExpanded = mediatingController.isSidebarExpanded.value
        layoutManager.handleRotation(to: size, isExpanded: isExpanded, coordinator: coordinator)
    }
    
    deinit {
        // Clean up observer
        mediatingController?.isSidebarExpanded.remove(observer: self)
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
        // Ensure coordinating controller is set
        if mainCoordinatingController == nil {
            let diContainer = appDIContainer ?? AppDIContainer()
            let mainSceneDIContainer = diContainer.makeMainSceneDIContainer()
            let newCoordinatingController = mainSceneDIContainer.makeMainCoordinatingController(delegate: self)
            // Setup side menu coordinating controller
            newCoordinatingController.setupSideMenuCoordinatingController()
            mainCoordinatingController = newCoordinatingController
        } else {
            // Ensure side menu coordinating controller is set up (in case it wasn't set up before)
            mainCoordinatingController?.setupSideMenuCoordinatingController()
        }
        
        guard let sideMenuVC = mainCoordinatingController?.makeSideMenuViewController() else {
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
    
    private func bind(to mediatingController: MainMediatingController) {
        // Use weak self to prevent retain cycles
        mediatingController.isSidebarExpanded.observe(on: self) { [weak self] expanded in
            self?.sideMenuState(expanded: expanded)
            self?.gestureProcessor.updateExpandedState(expanded)
        }
    }
    
    // MARK: - Content Management
    
    /// Set content view controller programmatically
    /// - Parameter contentViewController: The view controller to display as content
    func setContentViewController(_ contentViewController: UIViewController) {
        // Remove existing content view controller
        if let currentContent = currentContentViewController {
            currentContent.remove()
        }
        
        // Use contentContainerView if available, otherwise use main view
        let container = (contentContainerView ?? view)!
        
        // Add new content view controller using extension
        add(child: contentViewController, container: container)
        currentContentViewController = contentViewController
        mediatingController.setContentViewController(contentViewController)
        
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
            if mediatingController.isSidebarExpanded.value {
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


childVC.horizontalScrollOffset.observe(on: self) { [weak self] offset in
    print("User scrolled horizontally: \(offset)")
    // update UI hoặc animation theo offset
}
