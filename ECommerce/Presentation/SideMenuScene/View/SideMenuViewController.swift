//
//  SideMenuViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

final class SideMenuViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet private var headerImageView: UIImageView!
    @IBOutlet private var footerLabel: UILabel!
    
    private var controller: SideMenuController!
    private var sideMenuTableViewController: SideMenuTableViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with controller: SideMenuController
    ) -> SideMenuViewController {
        let view = SideMenuViewController.instantiateViewController()
        view.controller = controller
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupChildViewController()
        bind(to: controller)
        controller.viewDidLoad()
    }
    
    // MARK: - Private
    
    private func setupViews() {
        // Footer setup
        footerLabel.textColor = UIColor.white
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        footerLabel.text = controller.footerText
    }
    
    private func setupChildViewController() {
        // Create SideMenuTableViewController using the same controller
        let tableViewController = SideMenuTableViewController.create(with: controller)
        
        // Add as child view controller using extension
        add(tableViewController, to: sideMenuContainer)
        sideMenuTableViewController = tableViewController
    }
    
    private func bind(to controller: SideMenuController) {
        // Binding is handled by SideMenuTableViewController
        // No need to bind here as the table view controller manages its own updates
    }
}

extension SideMenuViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.controller.horizontalScrollOffset.value = scrollView.contentOffset.x
        }
}
