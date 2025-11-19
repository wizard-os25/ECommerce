//
//  MainMediatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import Foundation
import UIKit

struct MainMediatorActions {
    
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
}

protocol MainMediatingControllerOutput {
    var isSidebarExpanded: Observable<Bool> { get }
    var sidebarOffset: Observable<CGFloat> { get } // offset để MainVC animate
    var selectedContent: Observable<ContentType> { get }
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

    // MARK: - OUTPUT
    let isSidebarExpanded: Observable<Bool> = Observable(false)
    let sidebarOffset: Observable<CGFloat> = Observable(0)
    let selectedContent: Observable<ContentType> = Observable(.home)

    private let maxSidebarWidth: CGFloat = 260
    private var panStartOffset: CGFloat = 0

    private weak var coordinator: MainCoordinatingController?

    init(coordinator: MainCoordinatingController?) {
        self.coordinator = coordinator
    }

    // MARK: - INPUT
    func viewDidLoad() { }

    func toggleSidebar() {
        setSidebarExpanded(!isSidebarExpanded.value)
    }

    func setSidebarExpanded(_ expanded: Bool) {
        isSidebarExpanded.value = expanded
        sidebarOffset.value = expanded ? maxSidebarWidth : 0
    }

    func didSelectMenuItem(at index: Int) {
        switch index {
        case 0: selectedContent.value = .home
        case 1: selectedContent.value = .products
        case 2: selectedContent.value = .cart
        case 3: selectedContent.value = .profile
        default: break
        }

        setSidebarExpanded(false)

        coordinator?.showContent(type: selectedContent.value)
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
            panStartOffset = isSidebarExpanded.value ? maxSidebarWidth : 0

        case .changed:
            let newOffset = (panStartOffset + translationX)
            sidebarOffset.value = max(0, min(maxSidebarWidth, newOffset))

        case .ended:
            let shouldExpand = (sidebarOffset.value > maxSidebarWidth * 0.5)
            setSidebarExpanded(shouldExpand)

        default:
            break
        }
    }
}
