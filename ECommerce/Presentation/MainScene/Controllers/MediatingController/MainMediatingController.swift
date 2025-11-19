//
//  MainMediatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import Foundation
import UIKit

struct MainMediatorActions {
    /// Called when content type needs to be shown
    /// This delegates to the coordinator to handle content navigation
    let showContent: (ContentType) -> Void
    
    /// Optional callback when content view controller has changed
    /// Useful for tracking or analytics
    let onContentChanged: ((UIViewController) -> Void)?
    
    /// Optional callback when side menu is revealed
    let onSideMenuRevealed: (() -> Void)?
    
    /// Optional callback when side menu is hidden
    let onSideMenuHidden: (() -> Void)?
}

enum ContentType {
    case home
    case products
    case cart
    case profile
}

protocol MainMediatingControllerInput {
    func viewDidLoad()
    func toggleSidebar()
    func setSidebarExpanded(_ expanded: Bool)
    func didSelectMenuItem(at index: Int)
    func didPanGestureChanged(translationX: CGFloat, velocityX: CGFloat, state: UIGestureRecognizer.State)
    func didContentChanged(_ viewController: UIViewController)
}

protocol MainMediatingControllerOutput {
    var isSidebarExpanded: Observable<Bool> { get }
    var sidebarOffset: Observable<CGFloat> { get } // offset để MainVC animate
    var shadowAlpha: Observable<CGFloat> { get } // shadow alpha để MainVC animate
    var selectedContent: Observable<ContentType> { get }
    var animationTargetPosition: Observable<CGFloat> { get } // target position cho animation
    var contentViewPosition: Observable<CGFloat> { get } // content view position khi sidebar expanded
    var sideMenuRevealWidth: CGFloat { get }
    var revealSideMenuOnTop: Bool { get }
    var animationDuration: TimeInterval { get }
    var animationSpringDamping: CGFloat { get }
}

//protocol MainMediatingControllerInput {
//    func viewDidLoad()
//    func didSelectMenuItem(at index: Int)
//    func setSidebarExpanded(_ expanded: Bool)
//    func toggleSidebar()
//    //func setContentViewController(_ viewController: UIViewController)
//    func didPanGestureChanged(translationX: CGFloat, velocityX: CGFloat, state: UIGestureRecognizer.State)
//
//}
//
//protocol MainMediatingControllerOutput {
//    var isSidebarExpanded: Observable<Bool> { get }
//    var sidebarOffset: Observable<CGFloat> { get } // offset để MainVC animate
//
//    var currentContentViewController: UIViewController? { get }
//}

typealias MainMediatingController = MainMediatingControllerInput & MainMediatingControllerOutput

final class DefaultMainMediatingController: MainMediatingController {
    
    private let mainQueue: DispatchQueueType
    private let actions: MainMediatorActions?



    // MARK: - OUTPUT
    let isSidebarExpanded: Observable<Bool> = Observable(false)
    let sidebarOffset: Observable<CGFloat> = Observable(0)
    let selectedContent: Observable<ContentType> = Observable(.home)
    let shadowAlpha: Observable<CGFloat> = Observable(0.0)
    let animationTargetPosition: Observable<CGFloat> = Observable(0.0)
    let contentViewPosition: Observable<CGFloat> = Observable(0.0)
    
    // Configuration
    let sideMenuRevealWidth: CGFloat = 260
    let revealSideMenuOnTop: Bool = true
    let animationDuration: TimeInterval = 0.5
    let animationSpringDamping: CGFloat = 1.0

    private let maxSidebarWidth: CGFloat = 260
    private let velocityThreshold: CGFloat = 550.0
    
    // Gesture state
    private var panStartOffset: CGFloat = 0
    private var draggingIsEnabled: Bool = false

    init(
        mainQueue: DispatchQueueType = DispatchQueue.main,
        actions: MainMediatorActions? = nil
    ) {
        self.mainQueue = mainQueue
        self.actions = actions
    }

    // MARK: - INPUT
    func viewDidLoad() { }

    func toggleSidebar() {
        setSidebarExpanded(!isSidebarExpanded.value)
    }
    
    func didContentChanged(_ viewController: UIViewController) {
        actions?.onContentChanged?(viewController)
    }

    func setSidebarExpanded(_ expanded: Bool) {
        isSidebarExpanded.value = expanded
        sidebarOffset.value = expanded ? maxSidebarWidth : 0
        shadowAlpha.value = expanded ? 0.6 : 0.0
        
        // Calculate animation target position
        let targetPosition = expanded ? 0.0 : -sideMenuRevealWidth
        animationTargetPosition.value = targetPosition
        
        // Calculate content view position
        let contentX = expanded ? sideMenuRevealWidth : 0.0
        contentViewPosition.value = contentX
        
        // Call actions callbacks
        if expanded {
            actions?.onSideMenuRevealed?()
        } else {
            actions?.onSideMenuHidden?()
        }
    }

    func didSelectMenuItem(at index: Int) {
        let contentType: ContentType
        switch index {
        case 0: contentType = .home
        case 1: contentType = .products
        case 2: contentType = .cart
        case 3: contentType = .profile
        default: return
        }
        
        selectedContent.value = contentType
        setSidebarExpanded(false)
        
        // Use actions to show content (delegates to coordinator)
        actions?.showContent(contentType)
    }
}

extension DefaultMainMediatingController {

    func didPanGestureChanged(
        translationX: CGFloat,
        velocityX: CGFloat,
        state: UIGestureRecognizer.State
    ) {
        switch state {
        case .began:
            handlePanBegan(velocity: velocityX)
            
        case .changed:
            if draggingIsEnabled {
                handlePanChanged(translationX: translationX)
            }
            
        case .ended, .cancelled, .failed:
            if draggingIsEnabled {
                handlePanEnded(translationX: translationX, velocity: velocityX)
            }
            draggingIsEnabled = false
            
        default:
            break
        }
    }
    
    // MARK: - Private Gesture Handling
    
    private func handlePanBegan(velocity: CGFloat) {
        // If the user tries to expand the menu more than the reveal width, don't allow
        if velocity > 0 && isSidebarExpanded.value {
            return
        }
        
        // If the user swipes right but the side menu hasn't expanded yet, enable dragging
        if velocity > 0 && !isSidebarExpanded.value {
            draggingIsEnabled = true
            panStartOffset = 0.0
        }
        // If user swipes left and the side menu is already expanded, enable dragging
        else if velocity < 0 && isSidebarExpanded.value {
            draggingIsEnabled = true
            panStartOffset = maxSidebarWidth
        }
        
        if draggingIsEnabled {
            // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
            if abs(velocity) > velocityThreshold {
                setSidebarExpanded(!isSidebarExpanded.value)
                draggingIsEnabled = false
                return
            }
        }
    }
    
    private func handlePanChanged(translationX: CGFloat) {
        guard draggingIsEnabled else { return }
        
        // Calculate new position based on drag start
        let newOffset = panStartOffset + translationX
        
        // Clamp between 0 and maxSidebarWidth
        let clampedOffset = max(0.0, min(maxSidebarWidth, newOffset))
        
        // Update offset
        sidebarOffset.value = clampedOffset
        
        // Update shadow alpha based on progress
        let progress = clampedOffset / maxSidebarWidth
        shadowAlpha.value = progress * 0.6
        
        // Update content view position if not on top
        if !revealSideMenuOnTop {
            contentViewPosition.value = clampedOffset
        }
    }
    
    private func handlePanEnded(translationX: CGFloat, velocity: CGFloat) {
        guard draggingIsEnabled else { return }
        
        // Calculate final position
        let finalOffset = panStartOffset + translationX
        
        // Check if moved more than half
        let movedMoreThanHalf = finalOffset > maxSidebarWidth * 0.5
        
        // Consider velocity - if fast swipe, use velocity direction
        let shouldExpand: Bool
        if abs(velocity) > velocityThreshold {
            shouldExpand = velocity > 0
        } else {
            shouldExpand = movedMoreThanHalf
        }
        
        setSidebarExpanded(shouldExpand)
    }
}
