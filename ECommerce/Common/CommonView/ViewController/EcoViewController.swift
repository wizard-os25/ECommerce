//
//  EcoViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 8/1/26.
//

import UIKit

open class EcoViewController: EcoBaseViewController,
                              Alertable,
                              StoryboardInstantiable {

    // MARK: - Dependencies (late injection)

    public var controller: EcoController!

    // MARK: - Storyboard init

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        assert(controller != nil, "EcoController must be injected before viewDidLoad")

        bindCommon()
        controller.onViewDidLoad()
    }

    deinit {
        unbindCommon()
    }

    // MARK: - Common Binding

    open func bindCommon() {
        bindLoading()
        bindError()
        bindNavigation()
    }

    open func unbindCommon() {
        controller.loading.remove(observer: self)
        controller.error.remove(observer: self)
        controller.navigationState.remove(observer: self)
    }

    // MARK: - Binding Parts

    open func bindLoading() {
        controller.loading.observe(on: self) { [weak self] isLoading in
            self?.handleLoading(isLoading)
        }
    }

    open func bindError() {
        controller.error.observe(on: self) { [weak self] in
            self?.handleError($0) }
    }

    open func bindNavigation() {
        controller.navigationState.observe(on: self) { [weak self] state in
            self?.applyNavigation(state)
        }
    }

    // MARK: - Handlers

    open func handleLoading(_ isLoading: Bool) {
        isLoading ? EcoLoadingView.show() : EcoLoadingView.hide()
    }

    open func handleError(_ error: Error?) {
        guard let error else { return }
        showAlert(title: "error", message: error.localizedDescription)
    }

    open func applyNavigation(_ state: EcoNavigationState) {
        // Get callbacks from controller (using protocol extension defaults if not implemented)
        let callbacks = (
            onSearchTextChange: controller.onNavigationBarSearchTextChange,
            onSearchSubmit: controller.onNavigationBarSearchSubmit,
            onSearchClear: controller.onNavigationBarSearchClear,
            onLeftItemTap: controller.onNavigationBarLeftItemTap,
            onRightItemTap: controller.onNavigationBarRightItemTap,
            onCameraTap: controller.onNavigationBarCameraTap
        )
        
        if navigationBarViewController == nil {
            attachNavigationBar(
                initialState: state,
                onSearchTextChange: callbacks.onSearchTextChange,
                onSearchSubmit: callbacks.onSearchSubmit,
                onSearchClear: callbacks.onSearchClear,
                onLeftItemTap: callbacks.onLeftItemTap,
                onRightItemTap: callbacks.onRightItemTap,
                onCameraTap: callbacks.onCameraTap
            )
        } else {
            updateNavigationBar(state, animated: true)
            // Update callbacks after navigation bar is updated
            if let navBarController = navigationBarViewController?.controller as? DefaultEcoNavigationBarController {
                navBarController.onSearchTextChange = callbacks.onSearchTextChange
                navBarController.onSearchSubmit = callbacks.onSearchSubmit
                navBarController.onSearchClear = callbacks.onSearchClear
                navBarController.onLeftItemTap = callbacks.onLeftItemTap
                navBarController.onRightItemTap = callbacks.onRightItemTap
                navBarController.onCameraTap = callbacks.onCameraTap
            }
        }
    }
}
