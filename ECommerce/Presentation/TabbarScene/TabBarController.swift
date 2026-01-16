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
        
        // Set delegates to track navigation
        navTabContainer.delegate = self
        navGrocery.delegate = self
        navCart.delegate = self
        navAccount.delegate = self
        
        // Hide system navigation bar since we use custom EcoNavigationBar
        navTabContainer.isNavigationBarHidden = true
        navGrocery.isNavigationBarHidden = true
        navCart.isNavigationBarHidden = true
        navAccount.isNavigationBarHidden = true
        
        /// Set TabBar item - Home, Search, Cart, Notification
        contentVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        groceryVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        cartVC.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 2)
        accountVC.tabBarItem = UITabBarItem(title: "Notification", image: UIImage(systemName: "bell"), tag: 3)
        
        /// Set ViewController & Tabbar Item Color
        self.tabBar.tintColor = .black
        self.setViewControllers([navTabContainer, navGrocery, navCart, navAccount], animated: true)
        
        // Show TabBar initially (only on 4 main screens)
        updateTabBarVisibility()
    }
    
    // MARK: - TabBar Visibility Management
    
    func updateTabBarVisibility() {
        guard let selectedNav = selectedViewController as? UINavigationController else {
            tabBar.isHidden = false
            return
        }
        
        // Show TabBar only if we're at root view controller (one of 4 main screens)
        let isAtRoot = selectedNav.viewControllers.count == 1
        tabBar.isHidden = !isAtRoot
        
        // Also hide if sideMenu is open (check via MainContainerViewController)
        if let mainContainer = findMainContainerViewController() {
            // Check if sideMenu is expanded - this will be handled separately
        }
    }
    
    func hideTabBar() {
        tabBar.isHidden = true
    }
    
    func showTabBar() {
        // Only show if at root of selected navigation controller
        guard let selectedNav = selectedViewController as? UINavigationController else {
            tabBar.isHidden = false
            return
        }
        let isAtRoot = selectedNav.viewControllers.count == 1
        tabBar.isHidden = !isAtRoot
    }
    
    private func findMainContainerViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let vc = responder as? UIViewController,
               String(describing: type(of: vc)).contains("MainContainer") {
                return vc
            }
        }
        return nil
    }
}

// MARK: - UINavigationControllerDelegate

extension TabBarController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Hide TabBar when pushing (not at root)
        let isAtRoot = navigationController.viewControllers.count == 1
        tabBar.isHidden = !isAtRoot
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Update TabBar visibility after navigation completes
        updateTabBarVisibility()
    }
}

