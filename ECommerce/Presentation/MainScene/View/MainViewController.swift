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
    
    // MARK: - IBOutlets
    
    @IBOutlet private var contentContainerView: UIView? // Optional: may not be in storyboard
    
    // MARK: - Properties
    
    private var mediatingController: MainMediatingController!
    private var sideMenuViewController: SideMenuViewController!
    private let sideMenuRevealWidth: CGFloat = 260
    
    // Current content view controller
    private var currentContentViewController: UIViewController?
    
    // Dependencies
    private var mainCoordinatingController: MainCoordinatingController?
    private var sideMenuMediatingController: SideMenuMediatingController?
    
    
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
        setupChildVCComponents()
        //setupSideMenu()
        setupGestures()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
        // Content will be set by AppFlowCoordinator via onViewDidAppear callback
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
        mediatingController?.isSidebarExpanded.remove(observer: self)
        sideMenuMediatingController?.horizontalScrollOffset.remove(observer: self)
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    private func setupChildVCComponents() {
        self.add(sideMenuViewController, to: Self)
        self.sideMenuViewController.view.frame = CGRect(
            x: -self.sideMenuRevealWidth,
            y: 0,
            width: self.sideMenuRevealWidth,
            height: view.frame.height)
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
        
        mediatingController.sidebarOffset.observe(on: self) { [weak self] offset in
            guard let self else { return }
            UIView.animate(withDuration: 0.25) {
                self.sideMenuViewController.view.frame.origin.x = offset - self.sideMenuRevealWidth
            }
        }
        
        mediator.selectedContent.observe(on: self) { [weak self] type in
            guard let self else { return }
            let vc = self.makeContentVC(for: type)
            self.setContent(vc)
        }
    }
    
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).x
        let velocity = gesture.velocity(in: view).x
        mediator.didPanGestureChanged(
            translationX: translation,
            velocityX: velocity,
            state: gesture.state
        )
    }
}
