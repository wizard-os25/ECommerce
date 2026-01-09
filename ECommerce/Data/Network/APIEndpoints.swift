import Foundation

/// Main entry point for all API endpoints
/// Organizes endpoints by scene to keep code maintainable and scalable
/// 
/// **Note**: DTOs structs are mapped into Domains in repositories, 
/// and Repository protocols does not contain DTOs
struct APIEndpoints {
    
    // MARK: - Auth Endpoints
    
    /// Sign up endpoint
    static func signUp(with requestDTO: SignUpRequestDTO) -> Endpoint<SignUpResponseDTO> {
        return AuthEndpoints.signUp(with: requestDTO)
    }
    
    /// Login endpoint
    static func login(with requestDTO: LoginRequestDTO) -> Endpoint<LoginResponseDTO> {
        return AuthEndpoints.login(with: requestDTO)
    }
    
    /// Refresh token endpoint
    static func refreshToken(with requestDTO: RefreshTokenRequestDTO) -> Endpoint<RefreshTokenResponseDTO> {
        return AuthEndpoints.refreshToken(with: requestDTO)
    }
    
    /// Get user info endpoint
    static func getUserInfo() -> Endpoint<UserInfoResponseDTO> {
        return AuthEndpoints.getUserInfo()
    }
    
    // MARK: - Products Endpoints
    
    /// Get products endpoint
    static func getProducts(with requestDTO: ProductsRequestDTO) -> Endpoint<ProductsResponseDTO> {
        return ProductsEndpoints.getProducts(with: requestDTO)
    }
    
    // MARK: - Grocery Endpoints
    // Add grocery endpoints here when needed
    // Example:
    // static func getGroceryItems() -> Endpoint<GroceryResponseDTO> {
    //     return GroceryEndpoints.getGroceryItems()
    // }
}
