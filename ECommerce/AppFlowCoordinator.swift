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
        // In App Flow we can check if user needs to login, if yes we would run login flow
        let productsSceneDIContainer = appDIContainer.makeProductsSceneDIContainer()
        let flow = productsSceneDIContainer.makeProductCoordinatingController(navigationController: navigationController)
        flow.start()
    }
}
