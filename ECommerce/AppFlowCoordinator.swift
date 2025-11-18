import UIKit

final class AppFlowCoordinator {

    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    private var mainCoordinatingController: MainCoordinatingController?
    
    init(
        navigationController: UINavigationController,
        appDIContainer: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        // Create MainSceneDIContainer and MainCoordinatingController
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer()
        let mainCoordinatingController = mainSceneDIContainer.makeMainCoordinatingController(
            navigationController: navigationController,
            delegate: self
        )
        self.mainCoordinatingController = mainCoordinatingController
        
        // Start MainCoordinatingController - this will set MainViewController as root
        mainCoordinatingController.start()
    }
}

// MARK: - MainCoordinatingControllerDelegate

extension AppFlowCoordinator: MainCoordinatingControllerDelegate {
    
    func didSelectMenuItem(at index: Int) {
        // Handle menu item selection
        // This can navigate to different screens based on index
    }
    
    func didSetContentViewController(_ viewController: UIViewController) {
        // Content view controller was set
        // This can be used for tracking or additional setup if needed
    }
}
