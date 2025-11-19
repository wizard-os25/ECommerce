import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            queryParameters: [
                "api_key": appConfiguration.apiKey,
                "language": NSLocale.preferredLanguages.first ?? "en"
            ]
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()

    lazy var productsDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: appConfiguration.apiBaseURL)!
        )
        let productsDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: productsDataNetwork)
    }()
    
    // MARK: - DIContainers of scenes
    
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        let dependencies = MainSceneDIContainer.Dependencies(
            sideMenuSceneDIContainer: makeSideMenuSceneDIContainer(),
            productsSceneDIContainer: makeProductsSceneDIContainer()
        )
        return MainSceneDIContainer(dependencies: dependencies)
    }
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        let dependencies = SideMenuSceneDIContainer.Dependencies(
        )
        return SideMenuSceneDIContainer(dependencies: dependencies)
    }
    
    func makeProductsSceneDIContainer() -> ProductsSceneDIContainer {
        let dependencies = ProductsSceneDIContainer.Dependencies(
            productsDataTransferService: productsDataTransferService
        )
        return ProductsSceneDIContainer(dependencies: dependencies)
    }
}
