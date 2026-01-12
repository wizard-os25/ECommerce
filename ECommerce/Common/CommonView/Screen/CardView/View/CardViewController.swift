//
//  CardViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 10/1/26.
//

import UIKit

public final class CardViewController: EcoViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var contentContainerView: UIView!
    
    // MARK: - Properties
    
    private var cardController: CardController! {
        get { controller as? CardController }
    }
    
    // Parent view reference for calculations
    public weak var parentVC: UIViewController?
    
    // Animation
    private var runningAnimators: [UIViewPropertyAnimator] = []
    
    // Interactive dismissal
    private var panStartY: CGFloat = 0
    private var initialCardY: CGFloat = 0
    
    // Track initial position setup to avoid animating during setup
    private var isInitialPositionSet = false
    
    // Visual effects - blur effect view
    private var visualEffectView: UIVisualEffectView?
    
    // MARK: - Lifecycle
    
    public static func create(
        with cardController: CardController
    ) -> CardViewController {
        let viewController = CardViewController.instantiateViewController()
        // Inject controller for EcoViewController - DI pattern
        viewController.controller = cardController
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureIfNeeded()
        
        // Initially, view should be visible (will be hidden by binding if needed)
        // For onDemand mode, view starts hidden, but we'll show it when show() is called
        view.isHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateParentViewHeight()
        
        // Setup initial position only if not already set and card is not visible yet
        // This ensures the card starts from below screen, ready for animation
        if !isInitialPositionSet && !cardController.isVisible.value {
            setupInitialPosition()
        }
    }
    
    deinit {
        print("🔵 [CardViewController] deinit called")
        runningAnimators.forEach { $0.stopAnimation(true) }
        runningAnimators.removeAll()
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
        parentVC = nil
    }
    
    // MARK: - Common Binding Override
    
    public override func bindCommon() {
        super.bindCommon()
        bindCardSpecific()
    }
    
    // MARK: - Card-Specific Binding
    
    private func bindCardSpecific() {
        // Bind state changes - this is the main driver for animations
        cardController.state.observe(on: self) { [weak self] state in
            self?.updateUI(for: state)
        }
        
        // Bind currentY changes - only used for initial setup and tracking during pan gesture
        cardController.currentY.observe(on: self) { [weak self] y in
            guard let self = self, let y = y else { return }
            let currentState = self.cardController.state.value
            let isVisible = self.cardController.isVisible.value
            
            // For initial setup (before show is called): set position directly without animation
            if !self.isInitialPositionSet && currentState == .hidden && !isVisible {
                self.view.frame.origin.y = y
                self.isInitialPositionSet = true
                return
            }
            
            // Mark that initial setup is done
            if !self.isInitialPositionSet {
                self.isInitialPositionSet = true
            }
            
            // For pan gesture (during dragging), update position directly (no animation)
            // Animation is only handled by updateUI(for: state) when state changes
            // This observer is mainly for tracking position during interactive gestures
        }
        
        // Bind visibility changes
        cardController.isVisible.observe(on: self) { [weak self] isVisible in
            guard let self = self else { return }
            print("🔵 [CardViewController] isVisible changed: \(isVisible), state: \(self.cardController.state.value)")
            // Update view visibility
            // For show: make view visible (animation will be handled by updateUI when state changes)
            if isVisible {
                self.view.isHidden = false
            }
            // For hide: don't hide immediately - let dismiss animation complete first
            // Hiding is handled in updateUI(for: .hidden) completion
        }
        
        // Setup callbacks - cast to implementation type to set callbacks
        if let defaultCardController = cardController as? DefaultCardController {
            defaultCardController.onExpanded = { [weak self] in
                // Handle expanded callback if needed
                print("🔵 [CardViewController] onExpanded callback")
            }
            
            defaultCardController.onCollapsed = { [weak self] in
                // Handle collapsed callback if needed
                print("🔵 [CardViewController] onCollapsed callback")
            }
            
            defaultCardController.onDismissed = { [weak self] in
                // Handle dismissed callback if needed
                // Parent can listen to this and cleanup if needed
                print("🔵 [CardViewController] onDismissed callback - dismiss animation completed")
                // Note: CardViewController is still retained by parent
                // deinit will only be called when:
                // 1. Parent sets cardViewController = nil
                // 2. Parent calls detach() and sets cardViewController = nil
                // 3. Parent (ProductsViewController) is deallocated
            }
            
            defaultCardController.onShown = { [weak self] in
                // Handle shown callback if needed
                print("🔵 [CardViewController] onShown callback")
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
    }
    
    private func setupGestureIfNeeded() {
        guard cardController.configuration.enableGesture else { return }
        
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        view.addGestureRecognizer(pan)
    }
    
    // MARK: - Public Methods for Parent to Set Content
    
    /// Set content view controller into content container
    /// Parent should call this method to add their content
    /// - Parameter contentViewController: The view controller to embed as content
    public func setContent(_ contentViewController: UIViewController) {
        // Remove existing content
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        // Add new content
        addChild(contentViewController)
        contentContainerView.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
        
        contentViewController.didMove(toParent: self)
    }
    
    /// Set content view into content container
    /// Parent can use this method to add a custom view as content
    /// - Parameter contentView: The view to add as content
    public func setContentView(_ contentView: UIView) {
        // Remove existing content views
        contentContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add new content view
        contentContainerView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    /// Attach card to parent view controller
    /// Parent should call this method to add the card to their view hierarchy
    /// - Parameter parentVC: The parent view controller
    public func attach(to parentVC: UIViewController) {
        self.parentVC = parentVC
        parentVC.addChild(self)
        parentVC.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        // Setup blur effect view (behind card, in parent's view)
        setupBlurEffectView(in: parentVC.view)

        // Position card at bottom
        // Use constraints for width and height, but use transform for Y position animation
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: cardController.configuration.expandedHeight),
            // Bottom constraint will be used as base position, then we'll use transform to animate
            view.topAnchor.constraint(equalTo: parentVC.view.bottomAnchor)
        ])

        didMove(toParent: parentVC)
        updateParentViewHeight()
        
        // Setup initial position after layout
        // Use async to ensure view is laid out first
        DispatchQueue.main.async { [weak self] in
            self?.setupInitialPosition()
        }
    }
    
    private func setupBlurEffectView(in parentView: UIView) {
        visualEffectView = UIVisualEffectView()
        visualEffectView?.frame = parentView.bounds
        visualEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView?.isUserInteractionEnabled = false // Don't block touches - only visual effect
        parentView.insertSubview(visualEffectView!, belowSubview: view)
        visualEffectView?.effect = nil // Start with no blur
        visualEffectView?.alpha = 0 // Start invisible
    }
    
    /// Update parent view height (useful when called from outside)
    public func updateParentViewHeightIfNeeded() {
        updateParentViewHeight()
    }
    
    // MARK: - Private Helpers
    
    private func updateParentViewHeight() {
        guard let parent = parentVC else { return }
        let height = parent.view.bounds.height
        cardController.setParentViewHeight(height)
    }
    
    private func setupInitialPosition() {
        guard let parent = parentVC else { return }
        guard !isInitialPositionSet else { return } // Only set once
        
        // Ensure view is laid out first
        view.layoutIfNeeded()
        
        // Use transform to position card below screen (for onDemand mode)
        // This works with constraints - transform doesn't conflict with Auto Layout
        let initialY = calculateInitialY(in: parent.view)
        let baseY = parent.view.bounds.height // Base position from bottom constraint
        let transformY = initialY - baseY // Transform offset from base position
        view.transform = CGAffineTransform(translationX: 0, y: transformY)
        
        // Update currentY to match initial position (but won't animate because isVisible is false)
        // This ensures the position is tracked correctly
        if !cardController.isVisible.value {
            cardController.currentY.value = initialY
        }
        isInitialPositionSet = true
    }
    
    private func calculateInitialY(in parent: UIView) -> CGFloat {
        switch cardController.configuration.presentationMode {
        case .peek:
            return parent.bounds.height - cardController.configuration.collapsedHeight
        case .onDemand:
            // Start from below screen for present-like animation
            return parent.bounds.height + 50
        }
    }
    
    private func updateUI(for state: CardState) {
        guard let parent = parentVC else { return }
        let targetY = calculateY(for: state, in: parent.view)
        
        // For dismiss (hidden state), animate down then hide
        if state == .hidden {
            // Ensure view is visible before animating (in case it was already hidden)
            if view.isHidden {
                view.isHidden = false
            }
            // Animate down with spring animation (ngược lại với khi mở - chuyển động xuống dưới)
            animateToY(targetY) { [weak self] in
                // After animation completes, hide the view and cleanup
                guard let self = self else { return }
                self.view.isHidden = true
                // Hide and disable blur effect view to prevent blocking touches
                self.visualEffectView?.effect = nil
                self.visualEffectView?.alpha = 0
                self.visualEffectView?.isUserInteractionEnabled = false
                // Update visibility in controller (already set to false, but ensure sync)
                if self.cardController.isVisible.value {
                    self.cardController.updateVisibility(false)
                }
                // Notify parent that dismiss completed - parent can handle cleanup if needed
                self.notifyParentDismissCompleted()
            }
        } else {
            // For show/expand (expanded or collapsed state):
            // 1. Ensure view is visible
            if view.isHidden {
                view.isHidden = false
                // If view was hidden (after dismiss), reset initial position for animation
                // This ensures the card starts from below screen again
                let initialY = calculateInitialY(in: parent.view)
                let baseY = parent.view.bounds.height
                let transformY = initialY - baseY
                view.transform = CGAffineTransform(translationX: 0, y: transformY)
                // Ensure blur effect view is ready but doesn't block touches
                visualEffectView?.isUserInteractionEnabled = false
                visualEffectView?.alpha = 0
            }
            
            // 2. Ensure view is laid out before animating
            view.layoutIfNeeded()
            
            // 3. Always ensure initial position is set (below screen for onDemand mode)
            // This is critical for first show animation to work correctly
            if !isInitialPositionSet {
                let initialY = calculateInitialY(in: parent.view)
                let baseY = parent.view.bounds.height
                let transformY = initialY - baseY
                view.transform = CGAffineTransform(translationX: 0, y: transformY)
                isInitialPositionSet = true
                view.layoutIfNeeded()
            }
            
            // 4. Always animate from current position to target position
            // For first show: animate from below screen (initialY) to expanded position (targetY)
            // For subsequent shows: animate from current position to target position
            animateToY(targetY)
        }
    }
    
    private func calculateY(for state: CardState, in parent: UIView) -> CGFloat {
        switch state {
        case .hidden:
            // Hide completely below screen - no peek, completely hidden
            return parent.bounds.height + 100
        case .collapsed:
            // For full-screen-like, collapsed same as expanded
            return parent.bounds.height - cardController.configuration.expandedHeight
        case .expanded:
            // Expanded: cách đỉnh theo configuration (80pt)
            return parent.bounds.height - cardController.configuration.expandedHeight
        }
    }
    
    private func animateToY(_ y: CGFloat, completion: (() -> Void)? = nil) {
        // Stop any running animations first
        runningAnimators.forEach { $0.stopAnimation(true) }
        runningAnimators.removeAll()
        
        guard let parent = parentVC else {
            completion?()
            return
        }
        
        // Use transform for animation - this works with Auto Layout constraints
        // Base position is from bottom constraint (parent.view.bounds.height)
        let baseY = parent.view.bounds.height
        let targetTransformY = y - baseY
        
        let expandedY = parent.view.bounds.height - cardController.configuration.expandedHeight
        let isExpanding = abs(y - expandedY) < 10 // Close to expanded position
        
        // Use spring animation for smoother present-like effect (dâng từ dưới lên)
        // Damping ratio 0.75-0.85 gives natural bounce, duration 0.5-0.6s feels responsive
        let duration: TimeInterval = 0.55
        let dampingRatio: CGFloat = 0.82
        
        // Frame/Transform animator - main animation
        let frameAnimator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: targetTransformY)
                // Ensure corner radius is always 16
                self.view.layer.cornerRadius = 16
            }
        )
        
        frameAnimator.addCompletion { _ in
            completion?()
            self.runningAnimators.removeAll()
        }
        
        // Blur effect animator - only blur effect, keep it simple
        let blurAnimator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: dampingRatio,
            animations: {
                if isExpanding {
                    self.visualEffectView?.effect = UIBlurEffect(style: .systemMaterial)
                    self.visualEffectView?.alpha = 1.0
                    self.visualEffectView?.isUserInteractionEnabled = false // Never block touches
                } else {
                    self.visualEffectView?.effect = nil
                    self.visualEffectView?.alpha = 0
                    self.visualEffectView?.isUserInteractionEnabled = false
                }
            }
        )
        
        // Start animators
        frameAnimator.startAnimation()
        blurAnimator.startAnimation()
        
        runningAnimators = [frameAnimator, blurAnimator]
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let parent = parentVC else { return }
        
        let translation = recognizer.translation(in: parent.view)
        let velocity = recognizer.velocity(in: parent.view)
        
        switch recognizer.state {
        case .began:
            // Stop any running animations for smooth interactive dismissal
            runningAnimators.forEach { $0.stopAnimation(true) }
            runningAnimators.removeAll()
            
            // Store initial card position (calculate from transform and base position)
            let baseY = parent.view.bounds.height
            let currentTransformY = view.transform.ty
            initialCardY = baseY + currentTransformY
            
        case .changed:
            // Calculate new Y position based on translation (relative movement)
            // This ensures smooth following of finger movement
            let newY = initialCardY + translation.y
            
            // Allow dragging down to dismiss, but not above expanded position
            let expandedY = parent.view.bounds.height - cardController.configuration.expandedHeight
            let minY = expandedY
            let maxY = parent.view.bounds.height + 100 // Allow dragging below screen for smooth dismiss
            
            let clampedY = min(max(newY, minY), maxY)
            
            // Update view position using transform (follows finger naturally)
            let baseY = parent.view.bounds.height
            let transformY = clampedY - baseY
            view.transform = CGAffineTransform(translationX: 0, y: transformY)
            
            // Ensure corner radius is always 16
            view.layer.cornerRadius = 16
            
            // Update blur effect based on position (simple linear interpolation)
            let expandedYPosition = parent.view.bounds.height - cardController.configuration.expandedHeight
            let hiddenYPosition = parent.view.bounds.height + 100
            let totalRange = hiddenYPosition - expandedYPosition
            let currentProgress = (clampedY - expandedYPosition) / totalRange
            let blurProgress = 1 - min(max(currentProgress, 0), 1) // 1 when expanded, 0 when hidden
            
            // Update blur effect smoothly - always ensure it doesn't block touches
            visualEffectView?.isUserInteractionEnabled = false
            if blurProgress > 0.1 {
                visualEffectView?.effect = UIBlurEffect(style: .systemMaterial)
                visualEffectView?.alpha = blurProgress
            } else {
                visualEffectView?.effect = nil
                visualEffectView?.alpha = 0
            }
            
            // Update controller state for tracking
            cardController.currentY.value = clampedY
            
        case .ended, .cancelled:
            // Determine final state based on velocity and position
            // Calculate current Y from transform
            let baseY = parent.view.bounds.height
            let currentTransformY = view.transform.ty
            let currentY = baseY + currentTransformY
            let expandedY = parent.view.bounds.height - cardController.configuration.expandedHeight
            let dismissThreshold = expandedY + (cardController.configuration.expandedHeight * 0.3) // 30% down
            
            if velocity.y > 500 {
                // Fast swipe down - dismiss with animation
                cardController.didTapDismiss()
            } else if velocity.y < -300 {
                // Fast swipe up - snap back to expanded with spring animation
                animateToY(expandedY) {
                    // Update state to expanded after animation completes
                    if self.cardController.state.value != .expanded {
                        self.cardController.didTapExpand()
                    }
                }
            } else {
                // Check position - natural threshold based on drag distance
                if currentY > dismissThreshold {
                    // Dragged down more than 30% - dismiss
                    cardController.didTapDismiss()
                } else {
                    // Snap back to expanded position with spring animation
                    animateToY(expandedY) {
                        // Update state to expanded after animation completes
                        if self.cardController.state.value != .expanded {
                            self.cardController.didTapExpand()
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: - Public Actions
    
    /// Show the card (from hidden to expanded state - present-like)
    public func show() {
        cardController.didTapShow()
    }
    
    /// Expand the card (from collapsed to expanded state)
    public func expand() {
        cardController.didTapExpand()
    }
    
    /// Collapse the card (from expanded to collapsed state)
    public func collapse() {
        cardController.didTapCollapse()
    }
    
    /// Dismiss the card (hide it completely - no peek)
    public func dismiss() {
        cardController.didTapDismiss()
    }
    
    /// Detach card from parent view controller and cleanup all resources
    /// Parent should call this method when they want to fully remove the card
    public func detach() {
        // Stop all animations
        runningAnimators.forEach { $0.stopAnimation(true) }
        runningAnimators.removeAll()
        
        // Remove observers to prevent retain cycles
        removeObservers()
        
        // Remove blur effect view
        visualEffectView?.removeFromSuperview()
        visualEffectView = nil
        
        // Remove from parent view controller
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        
        // Clear parent reference
        parentVC = nil
        
        print("🔵 [CardViewController] detach() - Card removed and cleaned up")
    }
    
    /// Remove all observers to prevent memory leaks
    private func removeObservers() {
        guard let cardController = cardController else { return }
        
        // Observable uses weak references, but we should still clean up if possible
        // The Observable will automatically clean up deallocated observers, but
        // explicitly removing ensures immediate cleanup
        cardController.state.remove(observer: self)
        cardController.currentY.remove(observer: self)
        cardController.isVisible.remove(observer: self)
        
        // Clear callbacks
        if let defaultCardController = cardController as? DefaultCardController {
            defaultCardController.onExpanded = nil
            defaultCardController.onCollapsed = nil
            defaultCardController.onDismissed = nil
            defaultCardController.onShown = nil
        }
        
        print("🔵 [CardViewController] Observers removed")
    }
    
    /// Notify parent that dismiss completed
    /// Parent can handle cleanup (like removing reference) if needed
    private func notifyParentDismissCompleted() {
        // This callback is handled by onDismissed in CardController
        // Parent can listen to this callback and cleanup if needed
        // For now, we just log it
        print("🔵 [CardViewController] Dismiss completed - view hidden")
    }
    
}
