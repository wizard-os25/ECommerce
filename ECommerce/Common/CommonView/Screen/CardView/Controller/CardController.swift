//
//  CardController.swift
//  ECommerce
//
//  Created by wizard.os25 on 10/1/26.
//

import Foundation
import UIKit

// MARK: - Card Controller Input Protocol

public protocol CardControllerInput {
    func didTapShow()
    func didTapExpand()
    func didTapCollapse()
    func didTapDismiss()
    func didPanGesture(translation: CGFloat, velocity: CGFloat)
    func didPanGestureEnded(velocity: CGFloat)
    func setParentViewHeight(_ height: CGFloat)
    func viewDidLoad()
    func updateVisibility(_ visible: Bool)
}

// MARK: - Card Controller Output Protocol

public protocol CardControllerOutput {
    var state: Observable<CardState> { get }
    var currentY: Observable<CGFloat?> { get }
    var isVisible: Observable<Bool> { get }
    var configuration: CardConfiguration { get }
    
    // Callbacks
    var onExpanded: (() -> Void)? { get set }
    var onCollapsed: (() -> Void)? { get set }
    var onDismissed: (() -> Void)? { get set }
    var onShown: (() -> Void)? { get set }
}

// MARK: - Card Controller Typealias

public typealias CardController = CardControllerInput & CardControllerOutput & EcoController

// MARK: - Default Card Controller

public final class DefaultCardController: CardController {
    
    // MARK: - OUTPUT (Card-specific)
    
    public let state: Observable<CardState>
    public let currentY: Observable<CGFloat?>
    public let isVisible: Observable<Bool>
    public let configuration: CardConfiguration
    
    // MARK: - EcoController Output (common to all controllers)
    
    public let loading: Observable<Bool> = Observable(false)
    public let error: Observable<Error?> = Observable(nil)
    public let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Callbacks
    
    public var onExpanded: (() -> Void)?
    public var onCollapsed: (() -> Void)?
    public var onDismissed: (() -> Void)?
    public var onShown: (() -> Void)?
    
    // MARK: - Private
    
    private var model: CardModel
    private var parentViewHeight: CGFloat = 0
    
    // MARK: - Init
    
    public init(configuration: CardConfiguration) {
        self.configuration = configuration
        self.model = CardModel(configuration: configuration)
        self.state = Observable(model.state)
        self.currentY = Observable(model.currentY)
        self.isVisible = Observable(model.isVisible)
    }
    
    // MARK: - Private Helpers
    
    private func updateState(_ newState: CardState) {
        model.state = newState
        state.value = newState
    }
    
    public func updateVisibility(_ visible: Bool) {
        model.isVisible = visible
        isVisible.value = visible
    }
    
    private func updateCurrentY(_ y: CGFloat?) {
        model.currentY = y
        currentY.value = y
    }
    
    private func calculateY(for state: CardState, parentHeight: CGFloat) -> CGFloat {
        switch state {
        case .hidden:
            // Hide completely below screen - no peek
            return parentHeight + 100
        case .collapsed:
            return parentHeight - configuration.collapsedHeight
        case .expanded:
            // Expanded: cách đỉnh theo configuration
            return parentHeight - configuration.expandedHeight
        }
    }
    
    public func setParentViewHeight(_ height: CGFloat) {
        parentViewHeight = height
    }
}

// MARK: - INPUT Implementation

extension DefaultCardController {
    
    public func viewDidLoad() {
        // Initialize state based on configuration
        let initialState = configuration.presentationMode == .peek ? CardState.collapsed : CardState.hidden
        updateState(initialState)
        updateVisibility(configuration.presentationMode == .peek)
    }
    
    public func didTapShow() {
        guard !isVisible.value else { return }
        print("🔵 [CardController] didTapShow - parentViewHeight: \(parentViewHeight)")
        // Update state and position FIRST, then visibility
        // This ensures the view is ready to animate when it becomes visible
        updateState(.expanded)
        let y = calculateY(for: .expanded, parentHeight: parentViewHeight)
        print("🔵 [CardController] didTapShow - calculated Y: \(y)")
        updateCurrentY(y)
        // Update visibility last - this will trigger the animation
        updateVisibility(true)
        onShown?()
    }
    
    public func didTapExpand() {
        guard isVisible.value else { return }
        updateState(.expanded)
        let y = calculateY(for: .expanded, parentHeight: parentViewHeight)
        updateCurrentY(y)
        onExpanded?()
    }
    
    public func didTapCollapse() {
        guard isVisible.value, state.value == .expanded else { return }
        updateState(.collapsed)
        let y = calculateY(for: .collapsed, parentHeight: parentViewHeight)
        updateCurrentY(y)
        onCollapsed?()
    }
    
    public func didTapDismiss() {
        guard isVisible.value else { return }
        // First update state and position (this will trigger animation)
        updateState(.hidden)
        let y = calculateY(for: .hidden, parentHeight: parentViewHeight)
        updateCurrentY(y)
        // Visibility will be updated after animation completes (handled in view)
        onDismissed?()
    }
    
    public func didPanGesture(translation: CGFloat, velocity: CGFloat) {
        guard isVisible.value, let currentYValue = currentY.value else { return }
        
        let newY = currentYValue + translation
        // Allow dragging down to dismiss, but not above expanded position
        let minY = parentViewHeight - configuration.expandedHeight
        // Allow dragging down beyond screen to prepare for dismiss
        let maxY = parentViewHeight + 50 // Allow some extra space for smooth dismiss
        
        let clampedY = min(max(newY, minY), maxY)
        updateCurrentY(clampedY)
    }
    
    public func didPanGestureEnded(velocity: CGFloat) {
        guard isVisible.value, let currentYValue = currentY.value else { return }
        
        // For full-screen-like presentation: only expand or dismiss, no collapse
        let threshold = parentViewHeight - configuration.expandedHeight + (configuration.expandedHeight * 0.3) // 30% from top
        
        if velocity < -300 {
            // Swiping up fast - expand (if not already)
            if state.value != .expanded {
                didTapExpand()
            }
        } else if velocity > 300 {
            // Swiping down fast - dismiss completely
            didTapDismiss()
        } else {
            // No significant velocity - determine by position
            if currentYValue > threshold {
                // Swiped down more than 30% - dismiss
                didTapDismiss()
            } else {
                // Swiped down less than 30% - stay expanded
                if state.value != .expanded {
                    didTapExpand()
                }
            }
        }
    }
}

// MARK: - EcoController Implementation

extension DefaultCardController {
    
    public func onViewDidLoad() {
        // Initialize navigation state - CardView typically doesn't show navigation bar
        navigationState.value = EcoNavigationState(
            title: nil,
            showsSearch: false,
            searchState: nil,
            leftItem: nil,
            rightItems: [],
            background: .transparent,
            height: 0,
            collapsedHeight: 0
        )
        
        // Initialize card state
        viewDidLoad()
    }
    
    public func onViewWillAppear() {
        // Handle view will appear if needed
    }
    
    public func onViewDidDisappear() {
        // Handle view did disappear if needed
    }
}
