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
            baseURL: URL(string: appConfiguration.apiBaseURL)!,
            headers: [
                "X_API_KEY": appConfiguration.apiKey
            ]
        )
        let productsDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: productsDataNetwork)
    }()
    
    // MARK: - DIContainers of scenes
    
    func makeProductsSceneDIContainer() -> ProductsSceneDIContainer {
        let dependencies = ProductsSceneDIContainer.Dependencies(
            productsDataTransferService: productsDataTransferService
        )
        return ProductsSceneDIContainer(dependencies: dependencies)
    }
    
    func makeAuthSceneDIContainer() -> AuthSceneDIContainer {
        let dependencies = AuthSceneDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService,
            appDIContainer: self
        )
        return AuthSceneDIContainer(dependencies: dependencies)
    }
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        return SideMenuSceneDIContainer()
    }
    
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        let dependencies = MainSceneDIContainer.Dependencies(
            sideMenuSceneDIContainer: makeSideMenuSceneDIContainer(),
            appDIContainer: self
        )
        return MainSceneDIContainer(dependencies: dependencies)
    }
    
    func makeOnboardSceneDIContainer() -> OnboardSceneDIContainer {
        let dependencies = OnboardSceneDIContainer.Dependencies(
            authSceneDIContainer: makeAuthSceneDIContainer(),
            mainSceneDIContainer: makeMainSceneDIContainer()
        )
        return OnboardSceneDIContainer(dependencies: dependencies)
    }
}
