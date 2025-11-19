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
    
    // Override default implementation from StoryboardInstantiable extension
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
    private var sideMenuViewController: SideMenuViewController?
    private var currentContentViewController: UIViewController?
    
    private var sideMenuShadowView: UIView!
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    // Dependencies
    private var mainCoordinatingController: MainCoordinatingController?
    
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
        setupShadowView()
        setupGestures()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup will be done by coordinator after view appears
    }
    
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
    
    deinit {
        // Clean up observers
        mediatingController?.animationTargetPosition.remove(observer: self)
        mediatingController?.sidebarOffset.remove(observer: self)
        mediatingController?.contentViewPosition.remove(observer: self)
        mediatingController?.shadowAlpha.remove(observer: self)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func setupShadowView() {
        sideMenuShadowView = UIView(frame: view.bounds)
        sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sideMenuShadowView.backgroundColor = .black
        sideMenuShadowView.alpha = 0.0
        sideMenuShadowView.isUserInteractionEnabled = true
        
        if mediatingController.revealSideMenuOnTop {
            view.insertSubview(sideMenuShadowView, at: 1)
        }
    }
    
    private func setupGestures() {
        // Pan gesture for swipe to reveal/hide
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        self.panGestureRecognizer = panGesture
        
        // Tap gesture to dismiss sidebar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        sideMenuShadowView.addGestureRecognizer(tapGesture)
        self.tapGestureRecognizer = tapGesture
    }
    
    // MARK: - Content Management
    
    func setSideMenu(_ sideMenuViewController: SideMenuViewController) {
        // Remove old side menu if exists
        if let oldSideMenu = self.sideMenuViewController {
            oldSideMenu.remove()
        }
        
        self.sideMenuViewController = sideMenuViewController
        
        // Add side menu to view hierarchy
        if mediatingController.revealSideMenuOnTop {
            view.insertSubview(sideMenuViewController.view, at: 2)
        } else {
            view.insertSubview(sideMenuViewController.view, at: 0)
        }
        
        addChild(sideMenuViewController)
        sideMenuViewController.didMove(toParent: self)
        
        // Setup side menu layout
        sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        sideMenuViewController.view.frame = CGRect(
            x: -mediatingController.sideMenuRevealWidth,
            y: 0,
            width: mediatingController.sideMenuRevealWidth,
            height: view.bounds.height
        )
    }
    
    func setContent(_ viewController: UIViewController) {
        // Remove old content if exists
        if let oldContent = currentContentViewController {
            oldContent.remove()
        }
        
        currentContentViewController = viewController
        
        // Get container view or use main view
        let container: UIView = self.contentContainerView ?? view
        
        // Add content to view hierarchy
        viewController.view.tag = 99
        if mediatingController.revealSideMenuOnTop {
            container.insertSubview(viewController.view, at: 0)
        } else {
            container.insertSubview(viewController.view, at: 1)
        }
        
        addChild(viewController)
        
        // Setup content view layout
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: container.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Add shadow view to content if needed
        if !mediatingController.revealSideMenuOnTop, let contentView = viewController.view as? UIView {
            contentView.addSubview(sideMenuShadowView)
            sideMenuShadowView.frame = contentView.bounds
        }
        
        viewController.didMove(toParent: self)
        
        // Notify content changed through mediating controller
        mediatingController.didContentChanged(viewController)
    }
    
    // MARK: - Coordinator Setup
    
    func setupCoordinator(_ coordinator: MainCoordinatingController) {
        self.mainCoordinatingController = coordinator
        coordinator.setup(mainViewController: self)
    }
    
    // MARK: - Binding
    
    private func bind(to mediatingController: MainMediatingController) {
        // Observe sidebar expanded state - trigger animation
        mediatingController.animationTargetPosition.observe(on: self) { [weak self] targetPosition in
            self?.animateSideMenu(targetPosition: targetPosition)
        }
        
        // Observe sidebar offset for drag animation (real-time updates during drag)
        mediatingController.sidebarOffset.observe(on: self) { [weak self] offset in
            guard let self = self else { return }
            self.updateSideMenuPosition(offset: offset)
        }
        
        // Observe content view position
        mediatingController.contentViewPosition.observe(on: self) { [weak self] position in
            guard let self = self, !self.mediatingController.revealSideMenuOnTop else { return }
            self.currentContentViewController?.view.frame.origin.x = position
        }
        
        // Observe shadow alpha
        mediatingController.shadowAlpha.observe(on: self) { [weak self] alpha in
            self?.sideMenuShadowView.alpha = alpha
        }
    }
    
    // MARK: - Animation Methods
    
    private func animateSideMenu(targetPosition: CGFloat) {
        guard let sideMenuViewController = sideMenuViewController else { return }
        
        UIView.animate(
            withDuration: mediatingController.animationDuration,
            delay: 0,
            usingSpringWithDamping: mediatingController.animationSpringDamping,
            initialSpringVelocity: 0,
            options: .layoutSubviews,
            animations: {
                if self.mediatingController.revealSideMenuOnTop {
                    sideMenuViewController.view.frame.origin.x = targetPosition
                } else {
                    // Content position is handled by contentViewPosition observable
                    if let contentView = self.currentContentViewController?.view {
                        contentView.frame.origin.x = self.mediatingController.contentViewPosition.value
                    }
                }
            },
            completion: nil
        )
    }
    
    private func updateSideMenuPosition(offset: CGFloat) {
        // Update side menu position during drag (no animation)
        // Content view position is handled by contentViewPosition observable
        guard let sideMenuViewController = sideMenuViewController else { return }
        let xPosition = offset - mediatingController.sideMenuRevealWidth
        sideMenuViewController.view.frame.origin.x = xPosition
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).x
        let velocity = gesture.velocity(in: view).x
        
        mediatingController.didPanGestureChanged(
            translationX: translation,
            velocityX: velocity,
            state: gesture.state
        )
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            if mediatingController.isSidebarExpanded.value {
                mediatingController.setSidebarExpanded(false)
            }
        }
    }
    
    // MARK: - Rotation Handling
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            
            // Update side menu height
            if let sideMenuView = self.sideMenuViewController?.view {
                var frame = sideMenuView.frame
                frame.size.height = size.height
                sideMenuView.frame = frame
            }
            
            // Update side menu position based on expanded state (use animation target position)
            let targetX = self.mediatingController.animationTargetPosition.value
            self.sideMenuViewController?.view.frame.origin.x = targetX
            
            // Update content view position
            if !self.mediatingController.revealSideMenuOnTop, let contentView = self.currentContentViewController?.view {
                contentView.frame.origin.x = self.mediatingController.contentViewPosition.value
            }
            
            // Update shadow view frame
            self.sideMenuShadowView.frame = self.view.bounds
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't receive touch if it's on the side menu view
        if let sideMenuView = sideMenuViewController?.view,
           let touchView = touch.view,
           touchView.isDescendant(of: sideMenuView) {
            return false
        }
        
        // For tap gesture, only receive if sidebar is expanded
        if gestureRecognizer == tapGestureRecognizer {
            return mediatingController.isSidebarExpanded.value
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan gesture to work with scroll views
        if gestureRecognizer == panGestureRecognizer {
            return otherGestureRecognizer.view is UIScrollView
        }
        return false
    }
}
