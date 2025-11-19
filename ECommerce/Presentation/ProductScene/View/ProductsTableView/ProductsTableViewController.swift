//
//  ProductsTableViewController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductsTableViewController: UITableViewController, StoryboardInstantiable {
    
    var mediatingController: ProductsMediatingController!
    
    var nextPageLoadingSpinner: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
    }
    
    // MARK: - Sidebar Integration
    
    /// Setup sidebar reveal gesture using SidebarRevealBehavior
    private func setupSidebarGesture() {
        // Use SidebarRevealBehavior with custom action to find parent MainViewController and reveal sidebar
        addSidebarRevealBehavior { [weak self] in
            if let mainVC: MainViewController = self?.findParentViewController() {
                mainVC.revealSidebar()
            }
        }
        
        // For table view, also add swipe gesture directly to tableView
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRightGesture.direction = .right
        tableView.addGestureRecognizer(swipeRightGesture)
        
        // Add pan gesture to detect horizontal scroll for sidebar reveal
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        tableView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleSwipeRight() {
        // Find parent MainViewController and reveal sidebar
        if let mainVC: MainViewController = self.findParentViewController() {
            mainVC.revealSidebar()
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: tableView)
        let velocity = gesture.velocity(in: tableView)
        
        // Only handle horizontal pan gestures (right swipe)
        guard abs(velocity.x) > abs(velocity.y), velocity.x > 0 else {
            // Reset horizontal scroll offset if not horizontal or scrolling left
            updateHorizontalScrollOffset(0)
            return
        }
        
        // Update horizontal scroll offset based on translation
        // Only track positive (right) translation
        let horizontalOffset = max(0, translation.x)
        updateHorizontalScrollOffset(horizontalOffset)
        
        // Reset offset when gesture ends
        if gesture.state == .ended || gesture.state == .cancelled {
            updateHorizontalScrollOffset(0)
        }
    }
    
    /// Update horizontal scroll offset in SideMenuMediatingController
    /// - Parameter offset: The horizontal scroll offset
    private func updateHorizontalScrollOffset(_ offset: CGFloat) {
        // Find MainViewController and update horizontal scroll offset
        guard let mainVC: MainViewController = self.findParentViewController() else { return }
        mainVC.updateHorizontalScrollOffset(offset)
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func updateLoading(_ loading: Bool) {
        if loading && nextPageLoadingSpinner == nil {
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        } else if !loading {
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = nil
            tableView.tableFooterView = nil
        }
    }
    
    // MARK: - Private
    
    private func setupViews() {
        tableView.estimatedRowHeight = ProductItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func bind(to mediatingController: ProductsMediatingController) {
        mediatingController.items.observe(on: self) { [weak self] _ in
            self?.reload()
        }
        mediatingController.loading.observe(on: self) { [weak self] loading in
            self?.updateLoading(loading)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProductsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediatingController.items.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProductItemCell = tableView.dequeueReusableCell(at: indexPath)
        
        cell.fill(with: mediatingController.items.value[indexPath.row])
        
        if indexPath.row == mediatingController.items.value.count - 1 {
            mediatingController.didLoadNextPage()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mediatingController.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mediatingController.didSelectItem(at: indexPath.row)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ProductsTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow pan gesture to work simultaneously with table view scrolling
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Only handle pan gestures when table view is at the left edge
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let location = touch.location(in: tableView)
        
        // Only trigger if touch is near left edge (within 20 points)
        return location.x <= 20
    }
}
