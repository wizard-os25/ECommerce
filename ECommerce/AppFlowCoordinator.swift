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
        // Create MainSceneDIContainer and MainCoordinatingController
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer()
        let mainCoordinatingController = mainSceneDIContainer.makeMainCoordinatingController(
            navigationController: navigationController
        )
        
        // Start MainCoordinatingController - this will set MainViewController as root
        mainCoordinatingController.start()
    }
}
