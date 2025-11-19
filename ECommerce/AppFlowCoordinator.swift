import UIKit

final class AppFlowCoordinator {

    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(
        navigationController: UINavigationController,
        appDIContainer: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        // Create MainSceneDIContainer
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer()
        
        // Create MainViewController (coordinator is already set up inside)
        let mainViewController = mainSceneDIContainer.makeMainViewController()
        
        // Set MainViewController as root
        navigationController.setViewControllers([mainViewController], animated: false)
    }
}
