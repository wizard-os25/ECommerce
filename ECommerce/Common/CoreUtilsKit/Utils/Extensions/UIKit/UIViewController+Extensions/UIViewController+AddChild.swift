//
//  UIViewController+AddChild.swift
//  ECommerce
//
//  Created by wizard.os25 on 18/11/25.
//

import UIKit

// MARK: - Child ViewController
extension UIViewController {
    
    func add(_ child: UIViewController, to container: UIView) {
        addChild(child)
        child.view.frame = container.bounds
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeChildController(_ child: UIViewController) {
            guard parent != nil else { return }
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
}

