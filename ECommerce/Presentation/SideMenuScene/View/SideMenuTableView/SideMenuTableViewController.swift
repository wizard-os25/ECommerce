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
    
    // MARK: - Private
    
    private func setupViews() {
        // TableView setup
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0.3827145161, blue: 1, alpha: 1)
        tableView.separatorStyle = .none
        
        // Register TableView Cell
        tableView.register(cell: SideMenuCell.self)
    }
    
    private func bind(to mediatingController: SideMenuMediatingController) {
        mediatingController.menuItems.observe(on: self) { [weak self] _ in
            self?.updateMenuItems()
        }
        mediatingController.selectedIndex.observe(on: self) { [weak self] selectedIndex in
            self?.updateSelectedIndex(selectedIndex)
        }
    }
    
    private func updateMenuItems() {
        tableView.reloadData()
        updateSelectedIndex(mediatingController.selectedIndex.value)
    }
    
    private func updateSelectedIndex(_ index: Int) {
        guard index >= 0 && index < mediatingController.menuItems.value.count else { return }
        let indexPath = IndexPath(row: index, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    }
}

// MARK: - UITableViewDelegate

extension SideMenuTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mediatingController.didSelectMenuItem(at: indexPath.row)
        
        // Deselect certain items if needed
        if mediatingController.shouldDeselectItem(at: indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension SideMenuTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediatingController.menuItems.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SideMenuCell = tableView.dequeueReusableCell(at: indexPath)
        let menuItem = mediatingController.menuItems.value[indexPath.row]
        cell.fill(with: menuItem)
        
        // Highlighted color
        let selectionColorView = UIView()
        selectionColorView.backgroundColor = #colorLiteral(red: 0.6196078431, green: 0.1098039216, blue: 0.2509803922, alpha: 1)
        cell.selectedBackgroundView = selectionColorView
        
        return cell
    }
}
