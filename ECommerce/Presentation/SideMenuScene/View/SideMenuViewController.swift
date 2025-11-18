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
    
    private var mediatingController: SideMenuMediatingController!
    private var sideMenuTableViewController: SideMenuTableViewController?
    
    // MARK: - Lifecycle
    
    static func create(
        with mediatingController: SideMenuMediatingController
    ) -> SideMenuViewController {
        let view = SideMenuViewController.instantiateViewController()
        view.mediatingController = mediatingController
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupChildViewController()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
    }
    
    // MARK: - Private
    
    private func setupViews() {
        // Footer setup
        footerLabel.textColor = UIColor.white
        footerLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        footerLabel.text = mediatingController.footerText
    }
    
    private func setupChildViewController() {
        // Create SideMenuTableViewController using the same mediating controller
        let tableViewController = SideMenuTableViewController.create(with: mediatingController)
        
        // Add as child view controller using extension
        add(tableViewController, to: sideMenuContainer)
        sideMenuTableViewController = tableViewController
    }
    
    private func bind(to mediatingController: SideMenuMediatingController) {
        // Binding is handled by SideMenuTableViewController
        // No need to bind here as the table view controller manages its own updates
    }
}

extension SideMenuViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.mediatingController.horizontalScrollOffset.value = scrollView.contentOffset.x
        }
}
