//
//  SideMenuCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

protocol SideMenuCoordinatingControllerDependencies {
    //func makeSideMenuViewController(actions: SideMenuMediatorActions) -> SideMenuViewController
    func makeSideMenuItemViewController(for item: SideMenuModel) -> UIViewController
}

final class SideMenuCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: SideMenuCoordinatingControllerDependencies
    
    init(navigationController: UINavigationController,
         dependencies: SideMenuCoordinatingControllerDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    private func showSideMenuItems(item: SideMenuModel) {
        let vc = dependencies.makeSideMenuItemViewController(for: item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
