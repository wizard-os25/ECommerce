//
//  MainMediatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import Foundation
import UIKit

protocol MainMediatingControllerInput {
    func viewDidLoad()
    func didSelectMenuItem(at index: Int)
    func setSidebarExpanded(_ expanded: Bool)
    func toggleSidebar()
    func setContentViewController(_ viewController: UIViewController)
}

protocol MainMediatingControllerOutput {
    var isSidebarExpanded: Observable<Bool> { get }
    var currentContentViewController: UIViewController? { get }
}

typealias MainMediatingController = MainMediatingControllerInput & MainMediatingControllerOutput

final class DefaultMainMediatingController: MainMediatingController {
    
    // MARK: - OUTPUT
    
    let isSidebarExpanded: Observable<Bool> = Observable(false)
    var currentContentViewController: UIViewController?
    
    // MARK: - Private
    
    private weak var delegate: MainMediatingControllerDelegate?
    
    // MARK: - Init
    
    init(delegate: MainMediatingControllerDelegate? = nil) {
        self.delegate = delegate
    }
    
    // MARK: - INPUT
    
    func viewDidLoad() {
        // Initialize if needed
    }
    
    func didSelectMenuItem(at index: Int) {
        delegate?.didSelectMenuItem(at: index)
        setSidebarExpanded(false)
    }
    
    func setSidebarExpanded(_ expanded: Bool) {
        isSidebarExpanded.value = expanded
    }
    
    func toggleSidebar() {
        setSidebarExpanded(!isSidebarExpanded.value)
    }
    
    func setContentViewController(_ viewController: UIViewController) {
        currentContentViewController = viewController
    }
}

// MARK: - MainMediatingControllerDelegate

protocol MainMediatingControllerDelegate: AnyObject {
    func didSelectMenuItem(at index: Int)
}

