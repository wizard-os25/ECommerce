//
//  EcoBaseViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 8/1/26.
//

import UIKit

open class EcoBaseViewController: UIViewController {

    // MARK: - Navigation Bar

    public private(set) var navigationBarViewController: EcoNavigationBarViewController?
    private var navigationBarHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Keyboard Overlay
    
    private var keyboardOverlayView: UIView?
    private var keyboardObserverTokens: [NSObjectProtocol] = []

    // MARK: - Status Bar

    open var statusBarStyle: UIStatusBarStyle = .darkContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    // MARK: - Swipe Back Gesture

    open var isSwipeBackEnabled: Bool = true {
        didSet {
            updateSwipeBackGesture()
        }
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        configureBaseUI()
        setupKeyboardObservers()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSwipeBackGesture()
        syncStatusBarStyleFromNavigationBar()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardOverlay()
    }

    deinit {
        removeKeyboardObservers()
        detachNavigationBar()
    }
}

private extension EcoBaseViewController {

    func configureBaseUI() {
        view.backgroundColor = .systemBackground

        // Disable automatic inset adjustment
        if #available(iOS 11.0, *) {
            // handled by safeArea
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        // Hide system navigation bar if embedded
        navigationController?.isNavigationBarHidden = true
    }

    func updateSwipeBackGesture() {
        guard let navigationController else { return }
        navigationController.interactivePopGestureRecognizer?.isEnabled =
            isSwipeBackEnabled && navigationController.viewControllers.count > 1
    }

    func syncStatusBarStyleFromNavigationBar() {
        guard let navBarVC = navigationBarViewController else { return }
        statusBarStyle = navBarVC.currentStatusBarStyle
    }
    
    func setupKeyboardObservers() {
        let willShowToken = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillShow(notification)
        }
        
        let willHideToken = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillHide(notification)
        }
        
        keyboardObserverTokens = [willShowToken, willHideToken]
    }
    
    func removeKeyboardObservers() {
        keyboardObserverTokens.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        keyboardObserverTokens.removeAll()
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        showKeyboardOverlay(keyboardHeight: keyboardFrame.height)
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        removeKeyboardOverlay()
    }
    
    func showKeyboardOverlay(keyboardHeight: CGFloat) {
        // Remove existing overlay if any
        removeKeyboardOverlay()
        
        // Create overlay view
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.alpha = 0
        view.addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        // Overlay phủ từ dưới navigation bar tới hết màn hình (trên keyboard)
        let navBarBottom = navigationBarViewController?.view.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: navBarBottom),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardHeight)
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlay.addGestureRecognizer(tapGesture)
        
        keyboardOverlayView = overlay
        
        // Animate in
        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1.0
        }
    }
    
    func removeKeyboardOverlay() {
        guard let overlay = keyboardOverlayView else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
        }
        
        keyboardOverlayView = nil
    }
    
    @objc func overlayTapped() {
        view.endEditing(true)
    }
}

public extension EcoBaseViewController {

    // MARK: Attach

    func attachNavigationBar(
        initialState: EcoNavigationState = .init(),
        onSearchTextChange: ((String) -> Void)? = nil,
        onSearchSubmit: ((String) -> Void)? = nil,
        onSearchClear: (() -> Void)? = nil,
        onLeftItemTap: (() -> Void)? = nil,
        onRightItemTap: ((Int) -> Void)? = nil,
        onCameraTap: (() -> Void)? = nil
    ) {
        if navigationBarViewController == nil {
            let navBarVC = EcoNavigationBarViewController(initialState: initialState)
            
            // Setup callbacks
            if let controller = navBarVC.controller as? DefaultEcoNavigationBarController {
                controller.onSearchTextChange = onSearchTextChange
                controller.onSearchSubmit = onSearchSubmit
                controller.onSearchClear = onSearchClear
                controller.onLeftItemTap = onLeftItemTap
                controller.onRightItemTap = onRightItemTap
                controller.onCameraTap = onCameraTap
            }

            addChild(navBarVC)
            view.addSubview(navBarVC.view)
            navBarVC.didMove(toParent: self)

            navBarVC.view.translatesAutoresizingMaskIntoConstraints = false

            let height = initialState.height ?? EcoNavigationBarMetrics.barHeight
            let heightConstraint = navBarVC.view.heightAnchor
                .constraint(equalToConstant: height)

            navigationBarHeightConstraint = heightConstraint

            NSLayoutConstraint.activate([
                navBarVC.view.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
                ),
                navBarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBarVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                heightConstraint
            ])

            navigationBarViewController = navBarVC
            
            // Setup height change callback for scroll behavior
            navBarVC.setHeightChangeCallback { [weak self] newHeight in
                self?.updateNavigationBarHeight(newHeight, animated: true)
            }
        } else {
            navigationBarViewController?.updateState(initialState, animated: true)
            // Update callbacks
            if let controller = navigationBarViewController?.controller as? DefaultEcoNavigationBarController {
                controller.onSearchTextChange = onSearchTextChange
                controller.onSearchSubmit = onSearchSubmit
                controller.onSearchClear = onSearchClear
                controller.onLeftItemTap = onLeftItemTap
                controller.onRightItemTap = onRightItemTap
            }
        }

        syncStatusBarStyleFromNavigationBar()
    }

    // MARK: Update

    func updateNavigationBar(
        _ state: EcoNavigationState,
        animated: Bool = true
    ) {
        navigationBarViewController?.updateState(state, animated: animated)

        if let height = state.height {
            updateNavigationBarHeight(height, animated: animated)
        }

        syncStatusBarStyleFromNavigationBar()
    }

    // MARK: Height

    func updateNavigationBarHeight(
        _ height: CGFloat,
        animated: Bool = true
    ) {
        guard let constraint = navigationBarHeightConstraint else { return }

        let update = {
            constraint.constant = height
            self.view.layoutIfNeeded()
        }

        animated
            ? UIView.animate(withDuration: 0.25, animations: update)
            : update()
    }

    // MARK: Detach

    func detachNavigationBar() {
        guard let navBarVC = navigationBarViewController else { return }

        navBarVC.willMove(toParent: nil)
        navBarVC.view.removeFromSuperview()
        navBarVC.removeFromParent()

        navigationBarViewController = nil
        navigationBarHeightConstraint = nil
    }
}


public extension EcoBaseViewController {

    func bindNavigationBar(to scrollView: UIScrollView) {
        scrollView.delegate = self
    }

    func unbindNavigationBar(from scrollView: UIScrollView) {
        if scrollView.delegate === self {
            scrollView.delegate = nil
        }
    }
    
    /// Access to navigation bar controller for advanced usage
    var navigationBarController: EcoNavigationBarController? {
        navigationBarViewController?.controller
    }
}

extension EcoBaseViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navigationBarViewController?.handleScroll(
            offset: scrollView.contentOffset.y
        )
    }
}
