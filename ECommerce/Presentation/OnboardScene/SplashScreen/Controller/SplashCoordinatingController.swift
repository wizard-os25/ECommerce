//
//  SplashCoordinatingController.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import UIKit

protocol SplashCoordinatingControllerDependencies {
    func makeSplashViewController() -> SplashViewController
    func makeAuthSceneDIContainer() -> AuthSceneDIContainer
    func makeMainSceneDIContainer() -> MainSceneDIContainer
}

final class SplashCoordinatingController {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: SplashCoordinatingControllerDependencies
    private var window: UIWindow? // Keep strong reference to prevent deallocation
    
    init(
        navigationController: UINavigationController?,
        window: UIWindow?,
        dependencies: SplashCoordinatingControllerDependencies
    ) {
        self.navigationController = navigationController
        self.window = window
        self.dependencies = dependencies
    }
    
    func start() {
        print("SplashCoordinatingController: start() called")
        let viewController = dependencies.makeSplashViewController()
        print("SplashCoordinatingController: SplashViewController created")
        
        // Set coordinating controller BEFORE setting as root to ensure it's set before viewDidLoad
        viewController.setCoordinatingController(self)
        print("SplashCoordinatingController: CoordinatingController set, self = \(self)")
        
        // Set SplashViewController as root
        if let window = window {
            print("SplashCoordinatingController: Setting window rootViewController")
            // Make window key and visible first
            window.makeKeyAndVisible()
            window.rootViewController = viewController
            print("SplashCoordinatingController: Window rootViewController set")
        } else if let navigationController = navigationController {
            print("SplashCoordinatingController: Using navigationController")
            navigationController.setViewControllers([viewController], animated: false)
        } else {
            print("SplashCoordinatingController: ERROR - No window or navigationController!")
        }
    }
    
    // MARK: - Navigation
    
    func navigateToMain() {
        let mainSceneDIContainer = dependencies.makeMainSceneDIContainer()
        let mainContainerViewController = mainSceneDIContainer.makeMainContainerViewController()
        
        transitionToRootViewController(mainContainerViewController)
    }
    
    func navigateToLogin() {
        let authSceneDIContainer = dependencies.makeAuthSceneDIContainer()
        let navigationController = UINavigationController()
        let loginCoordinatingController = authSceneDIContainer.makeLoginCoordinatingController(
            navigationController: navigationController
        )
        
        // LoginCoordinatingController is now kept alive via associated object in navigationController
        // Start LoginCoordinatingController which will set coordinatingController and push LoginViewController
        loginCoordinatingController.start()
        
        transitionToRootViewController(navigationController)
    }
    
    // MARK: - Private Helpers
    
    private func transitionToRootViewController(_ viewController: UIViewController) {
        guard let window = window ?? navigationController?.view.window else {
            print("SplashCoordinatingController: No window available for transition")
            return
        }
        
        print("SplashCoordinatingController: Transitioning to \(type(of: viewController))")
        
        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = viewController
            },
            completion: { finished in
                print("SplashCoordinatingController: Transition completed: \(finished)")
            }
        )
    }
}
