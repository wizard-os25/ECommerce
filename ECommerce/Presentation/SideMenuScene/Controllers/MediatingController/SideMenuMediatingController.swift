//
//  SideMenuMediatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import Foundation
import UIKit

struct SideMenuMediatorActions {
    let showMenuItemType: (SideMenuModel) -> Void
}

protocol SideMenuMediatingControllerInput {
    func viewDidLoad()
    func didReveal()
    func didSelectMenuItem(at index: Int)
}

protocol SideMenuMediatingControllerOutput {
    var menuItems: Observable<[SideMenuModel]> { get }
    var horizontalScrollOffset: Observable<CGFloat> { get }
    var isEmpty: Bool { get }
    //var screenTitle: String { get }
    var footerText: String { get }
}

typealias SideMenuMediatingController = SideMenuMediatingControllerInput & SideMenuMediatingControllerOutput

final class DefaultSideMenuMediatingController: SideMenuMediatingController {
    
    private let actions: SideMenuMediatorActions?
    
    private let mainQueue: DispatchQueueType
    //var screenTitle = NSLocalizedString("", comment: "")
    
    // MARK: - OUTPUT
    
    let menuItems: Observable<[SideMenuModel]> = Observable([])
    let horizontalScrollOffset: Observable<CGFloat> = Observable(0)
    var isEmpty: Bool { return self.menuItems.value.isEmpty}
    let footerText: String = "Version 1.1"
    
    // MARK: - Init
    
    init(
        actions: SideMenuMediatorActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.menuItems.value = defaultMenuItems
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private let defaultMenuItems = SideMenuType.allCases.map { $0.model }
}
    
    // MARK: - INPUT. View event methods

extension DefaultSideMenuMediatingController {
    func viewDidLoad() {
        // Initialize menu items if needed
        if menuItems.value.isEmpty {
            menuItems.value = defaultMenuItems
        }
    }
    
    func didReveal() {
        
    }

    func didSelectMenuItem(at index: Int) {
        self.actions?.showMenuItemType(self.defaultMenuItems[index])
    }
}
