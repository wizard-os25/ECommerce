//
//  SideMenuTableViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

final class SideMenuTableViewController: UITableViewController, StoryboardInstantiable {
    
    private var mediatingController: SideMenuMediatingController!

    
    // MARK: - Lifecycle
    
    static func create(
        with mediatingController: SideMenuMediatingController
    ) -> SideMenuTableViewController {
        let viewController = SideMenuTableViewController.instantiateViewController()
        viewController.mediatingController = mediatingController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: mediatingController)
        mediatingController.viewDidLoad()
    }
    
    private func bind(to mediatingController: SideMenuMediatingController) {
        
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    // MARK: - Private
    
    private func setupViews() {
        // TableView setup
        tableView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        //tableView.separatorStyle = .none
        
        // Register TableView Cell
        tableView.register(cell: SideMenuCell.self)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SideMenuTableViewController {
    /// Maybe cause crash if TableView not use dynamic-height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.mediatingController.isEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }
       
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediatingController.isEmpty ? 1 : self.mediatingController.menuItems.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if self.mediatingController.isEmpty {} else {}
        let cell: SideMenuCell = tableView.dequeueReusableCell(at: indexPath)
        let menuItem = self.mediatingController.menuItems.value[indexPath.row]
        cell.fill(with: menuItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mediatingController.didSelectMenuItem(at: indexPath.row)
    }

}
