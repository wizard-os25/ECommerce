//
//  ProductsEndpoints.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import Foundation

enum ProductsEndpoints {
    
    // MARK: - Products
    
    static func getProducts(with requestDTO: ProductsRequestDTO) -> Endpoint<ProductsResponseDTO> {
        return Endpoint(
            path: "api/v1/products/\(requestDTO.query)",
            method: .get,
            queryParametersEncodable: ProductsQueryDTO(
                page: requestDTO.page,
                pageSize: requestDTO.pageSize
            )
        )
    }
    
    // MARK: - Private Helpers
    
    private struct ProductsQueryDTO: Encodable {
        let page: Int
        let pageSize: Int
        
        enum CodingKeys: String, CodingKey {
            case page
            case pageSize
        }
    }
}
