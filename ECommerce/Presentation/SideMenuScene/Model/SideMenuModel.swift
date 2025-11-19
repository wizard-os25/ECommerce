//
//  SideMenuModel.swift
//  SideMenu-IOS-Swift
//
//  Created by apple on 12/01/22.
//
import UIKit

struct SideMenuModel {
    var icon: UIImage
    var title: String
}

enum SideMenuType: CaseIterable {
    case home, products, cart, profile, settings

    var model: SideMenuModel {
        switch self {
        case .home:
            return SideMenuModel(
                icon: UIImage(systemName: "house.fill")!,
                title: "home".localized()
            )
        case .products:
            return SideMenuModel(
                icon: UIImage(systemName: "bag.fill")!,
                title: "products".localized()
            )
        case .cart:
            return SideMenuModel(
                icon: UIImage(systemName: "cart.fill")!,
                title: "cart".localized()
            )
        case .profile:
            return SideMenuModel(
                icon: UIImage(systemName: "person.fill")!,
                title: "profile".localized()
            )
        case .settings:
            return SideMenuModel(
                icon: UIImage(systemName: "slider.horizontal.3")!,
                title: "settings".localized()
            )
        }
    }
}
