//
//  AppDelegate.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import UIKit
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appConfiguration = AppConfiguration()
    let appDIContainer = AppDIContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?
    var splashCoordinatingController: SplashCoordinatingController? // Keep strong reference
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        StripeAPI.defaultPublishableKey = self.appConfiguration.stripePulishableKey
        AppAppearance.setupAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set SplashViewController as entry point
        let onboardSceneDIContainer = self.appDIContainer.makeOnboardSceneDIContainer()
        self.splashCoordinatingController = onboardSceneDIContainer.makeSplashCoordinatingController(
            navigationController: nil,
            window: window
        )
        self.splashCoordinatingController?.start()
        // Note: window.makeKeyAndVisible() is called inside start() method
    
        return true
    }

//    func applicationDidEnterBackground(_ application: UIApplication) {
//        CoreDataStorage.shared.saveContext()
//    }
}
