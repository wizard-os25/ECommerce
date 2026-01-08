//
//  AppDelegate.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appDIContainer = AppDIContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        AppAppearance.setupAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set MainContainerViewController as entry point
        let mainContainerViewController = MainContainerViewController()
        window?.rootViewController = mainContainerViewController
        window?.makeKeyAndVisible()
    
        return true
        
        // MARK: - Old Flow (Commented)
                // Old logic using AppFlowCoordinator with MainViewController
                /*
                let navigationController = UINavigationController()
                window?.rootViewController = navigationController
                appFlowCoordinator = AppFlowCoordinator(
                    navigationController: navigationController,
                    appDIContainer: appDIContainer
                )
                appFlowCoordinator?.start()
                window?.makeKeyAndVisible()
                */
    }

//    func applicationDidEnterBackground(_ application: UIApplication) {
//        CoreDataStorage.shared.saveContext()
//    }
}
