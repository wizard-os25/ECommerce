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
    var splashCoordinatingController: SplashCoordinatingController? // Keep strong reference
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        AppAppearance.setupAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set SplashViewController as entry point
        let onboardSceneDIContainer = appDIContainer.makeOnboardSceneDIContainer()
        splashCoordinatingController = onboardSceneDIContainer.makeSplashCoordinatingController(
            navigationController: nil,
            window: window
        )
        splashCoordinatingController?.start()
        // Note: window.makeKeyAndVisible() is called inside start() method
    
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
