import Foundation

struct APIEndpoints {
    
    static func getProducts(with productsRequestDTO: ProductsRequestDTO) -> Endpoint<ProductsResponseDTO> {
        return Endpoint(
            path: "api/v1/products/\(productsRequestDTO.query)",
            method: .get,
            queryParametersEncodable: ProductsQueryDTO(page: productsRequestDTO.page, pageSize: productsRequestDTO.pageSize)
        )
    }
    
    private struct ProductsQueryDTO: Encodable {
        let page: Int
        let pageSize: Int
        
        enum CodingKeys: String, CodingKey {
            case page
            case pageSize
        }
    }
}
