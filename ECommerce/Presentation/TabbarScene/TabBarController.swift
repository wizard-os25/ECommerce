//
//  TabBarController.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 3/6/25.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🟢 TabBarController loaded thành công")
        
        // Tab 0: Home (ContentViewController với SegmentedPageContainer)
        let contentVC = ContentViewController()
        
        // Tab 1: Grocery - Simple view controller
        let groceryVC = UIViewController()
        groceryVC.view.backgroundColor = .systemPurple
        groceryVC.title = "Grocery"
        
        // Tab 2: Cart - Simple view controller
        let cartVC = UIViewController()
        cartVC.view.backgroundColor = .systemOrange
        cartVC.title = "Cart"
        
        // Tab 3: Account - Simple view controller
        let accountVC = UIViewController()
        accountVC.view.backgroundColor = .systemGreen
        accountVC.title = "Account"
        
        // Wrap in Navigation Controllers
        let navTabContainer = UINavigationController(rootViewController: contentVC)
        let navGrocery = UINavigationController(rootViewController: groceryVC)
        let navCart = UINavigationController(rootViewController: cartVC)
        let navAccount = UINavigationController(rootViewController: accountVC)
        
        /// Set TabBar item
        contentVC.tabBarItem = UITabBarItem(title: "Bazaar", image: UIImage(systemName: "house"), tag: 0)
        groceryVC.tabBarItem = UITabBarItem(title: "Grocery", image: UIImage(systemName: "cart.fill"), tag: 1)
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 2)
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), tag: 3)
        
        /// Set ViewController & Tabbar Item Color
        self.tabBar.tintColor = .black
        self.setViewControllers([navTabContainer, navGrocery, navCart, navAccount], animated: true)
    }
}

