//
//  SideMenuMediatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import Foundation
import UIKit

protocol SideMenuMediatingControllerInput {
    func viewDidLoad()
    func didSelectMenuItem(at index: Int)
}

protocol SideMenuMediatingControllerOutput {
    var menuItems: Observable<[SideMenuModel]> { get }
    var selectedIndex: Observable<Int> { get }
    //
    var horizontalScrollOffset: Observable<CGFloat> { get }
    var footerText: String { get }
    func shouldDeselectItem(at index: Int) -> Bool
}

typealias SideMenuMediatingController = SideMenuMediatingControllerInput & SideMenuMediatingControllerOutput

final class DefaultSideMenuMediatingController: SideMenuMediatingController {
    
    // MARK: - OUTPUT
    
    let menuItems: Observable<[SideMenuModel]> = Observable([])
    let selectedIndex: Observable<Int> = Observable(0)
    let horizontalScrollOffset: Observable<CGFloat> = Observable(0)
    let footerText: String = "Version 1.1"
    
    // MARK: - Private
    
    private let defaultMenuItems: [SideMenuModel] = [
        SideMenuModel(icon: UIImage(systemName: "house.fill")!, title: "home".localized()),
        SideMenuModel(icon: UIImage(systemName: "bag.fill")!, title: "products".localized()),
        SideMenuModel(icon: UIImage(systemName: "cart.fill")!, title: "cart".localized()),
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, title: "profile".localized()),
        SideMenuModel(icon: UIImage(systemName: "slider.horizontal.3")!, title: "settings".localized())
    ]
    
    // MARK: - Init
    
    init() {
        menuItems.value = defaultMenuItems
    }
    
    // MARK: - INPUT
    
    func viewDidLoad() {
        // Initialize menu items if needed
        if menuItems.value.isEmpty {
            menuItems.value = defaultMenuItems
        }
    }
    
    func didSelectMenuItem(at index: Int) {
        guard index >= 0 && index < menuItems.value.count else { return }
        selectedIndex.value = index
    }
    
    func shouldDeselectItem(at index: Int) -> Bool {
        // Profile (index 3) and Settings (index 4) should be deselected after selection
        return index == 3 || index == 4
    }
}
