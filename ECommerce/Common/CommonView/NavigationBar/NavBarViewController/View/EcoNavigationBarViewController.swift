//
//  EcoNavigationBarViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 8/1/26.
//

import UIKit

/// UIViewController that binds NavigationBarController and NavigationBarView
/// Similar to ProductsViewController pattern
public final class EcoNavigationBarViewController: UIViewController {
    
    // MARK: - Properties
    
    private var navigationBarController: EcoNavigationBarController!
    private let navigationBarView: EcoNavigationBarView
    
    // MARK: - Init
    
    public init(controller: EcoNavigationBarController) {
        self.navigationBarController = controller
        self.navigationBarView = EcoNavigationBarView()
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(initialState: EcoNavigationState = .init()) {
        let controller = DefaultEcoNavigationBarController(initialState: initialState)
        self.init(controller: controller)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(to: navigationBarController)
        navigationBarController.viewDidLoad()
    }
    
    deinit {
        unbind()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view = navigationBarView
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        // Ensure view can receive touch events
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
    }
    
    // MARK: - Binding
    
    private func bind(to controller: EcoNavigationBarController) {
        // Bind state changes to view rendering
        controller.state.observe(on: self) { [weak self] state in
            self?.render(state: state)
        }
        
        // Bind search field events to controller
        setupSearchFieldBindings()
    }
    
    private func unbind() {
        navigationBarController.state.remove(observer: self)
        navigationBarController.statusBarStyle.remove(observer: self)
    }
    
    private func setupSearchFieldBindings() {
        let searchField = navigationBarView.searchField
        
        searchField.onTextChange = { [weak self] text in
            self?.navigationBarController.didSearchTextChange(text)
        }
        
        searchField.onSubmit = { [weak self] text in
            self?.navigationBarController.didSearchSubmit(text)
        }
        
        searchField.onClear = { [weak self] in
            self?.navigationBarController.didSearchClear()
        }
        
        searchField.onCameraTap = { [weak self] in
            if let controller = self?.navigationBarController as? DefaultEcoNavigationBarController {
                controller.onCameraTap?()
            }
        }
        
        // Setup item tap handlers to route through controller
        navigationBarView.onLeftItemTap = { [weak self] in
            self?.navigationBarController.didLeftItemTap()
        }
        
        navigationBarView.onRightItemTap = { [weak self] index in
            self?.navigationBarController.didRightItemTap(at: index)
        }
    }
    
    private func render(state: EcoNavigationState) {
        navigationBarView.render(state: state, animated: true)
    }
}

// MARK: - Public API

public extension EcoNavigationBarViewController {
    
    /// Access to the underlying controller
    var controller: EcoNavigationBarController {
        navigationBarController
    }
    
    /// Get current status bar style
    var currentStatusBarStyle: UIStatusBarStyle {
        navigationBarController.statusBarStyle.value
    }
    
    /// Update navigation bar state
    func updateState(_ state: EcoNavigationState, animated: Bool = true) {
        navigationBarController.didUpdateState(state)
    }
    
    /// Handle scroll updates
    func handleScroll(offset: CGFloat) {
        navigationBarController.didScrollUpdate(progress: offset)
        navigationBarView.updateScroll(progress: offset)
    }
    
    /// Set callback for height changes during scroll
    func setHeightChangeCallback(_ callback: @escaping (CGFloat) -> Void) {
        navigationBarView.onHeightChange = callback
    }
    
    /// Get search text field for external configuration
    var searchField: EcoSearchTextField {
        navigationBarView.searchField
    }
    
    /// Convenience methods that delegate to controller
    func setTitle(_ title: String?) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.setTitle(title)
        }
    }
    
    func showSearch(_ show: Bool) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.showSearch(show)
        }
    }
    
    func setBackground(_ background: EcoNavigationBackground) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.setBackground(background)
        }
    }
    
    func setLeftItem(_ item: EcoNavItem?) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.setLeftItem(item)
        }
    }
    
    func setRightItems(_ items: [EcoNavItem]) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.setRightItems(items)
        }
    }
    
    func update(_ block: (inout EcoNavigationState) -> Void) {
        if let controller = navigationBarController as? DefaultEcoNavigationBarController {
            controller.update(block)
        }
    }
}

// MARK: - Navigation Bar Metrics

public struct EcoNavigationBarMetrics {
    public static let height: CGFloat = 44.0 + UIApplication.shared.statusBarFrame.height
    public static let barHeight: CGFloat = 44.0
}

