import Foundation

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        // Keep api_key in query parameters for existing working cases
        // Bearer token will be added to Authorization header when available (for authenticated endpoints)
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
    
    func makeAddressDIContainer() -> AddressDIContainer {
        let dependencies = AddressDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService
        )
        return AddressDIContainer(dependencies: dependencies)
    }
    
    func makeLocationListDIContainer() -> LocationListDIContainer {
        let dependencies = LocationListDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService
        )
        return LocationListDIContainer(dependencies: dependencies)
    }
    
    func makeProfileDIContainer() -> ProfileDIContainer {
        let dependencies = ProfileDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService
        )
        return ProfileDIContainer(dependencies: dependencies)
    }
    
    func makePaymentCardDIContainer() -> PaymentCardDIContainer {
        let dependencies = PaymentCardDIContainer.Dependencies(
            paymentCardDataTransferService: apiDataTransferService
        )
        return PaymentCardDIContainer(dependencies: dependencies)
    }
    
    // Shared instance to ensure same SideMenuController is used everywhere
    private lazy var sharedSideMenuSceneDIContainer: SideMenuSceneDIContainer = {
        let dependencies = SideMenuSceneDIContainer.Dependencies(
            addressDIContainer: makeAddressDIContainer(),
            paymentCardDIContainer: makePaymentCardDIContainer()
        )
        return SideMenuSceneDIContainer(dependencies: dependencies)
    }()
    
    func makeSideMenuSceneDIContainer() -> SideMenuSceneDIContainer {
        return sharedSideMenuSceneDIContainer
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
