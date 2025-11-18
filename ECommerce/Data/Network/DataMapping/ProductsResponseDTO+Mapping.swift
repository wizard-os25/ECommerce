//
//  ProductsResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import Foundation

// MARK: - Data Transfer Object

struct ProductsResponseDTO: Decodable {
    let contents: [ProductDTO]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let hasMore: Bool
    let additionalInfo: Any?
    
    enum CodingKeys: String, CodingKey {
        case contents
        case page
        case pageSize
        case totalElements
        case hasMore
        case additionalInfo
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contents = try container.decode([ProductDTO].self, forKey: .contents)
        page = try container.decode(Int.self, forKey: .page)
        pageSize = try container.decode(Int.self, forKey: .pageSize)
        totalElements = try container.decode(Int.self, forKey: .totalElements)
        hasMore = try container.decode(Bool.self, forKey: .hasMore)
        additionalInfo = try? container.decodeIfPresent(String.self, forKey: .additionalInfo)
    }
}

extension ProductsResponseDTO {
    struct ProductDTO: Decodable {
        let id: Int
        let name: String?
        let description: String?
        let price: String?
        let stars: Int?
        let location: String?
        let image: ProductImageDTO
    }
    
    struct ProductImageDTO: Decodable {
        let url: String?
        let blurhash: String?
        let width: Int?
        let height: Int?
    }
}

// MARK: - Mappings to Domain

extension ProductsResponseDTO {
    func toDomain() -> ProductPage {
        return .init(
            contents: contents.map { $0.toDomain() },
            page: page,
            pageSize: pageSize,
            totalElements: totalElements,
            hasMore: hasMore,
            additionalInfo: additionalInfo
        )
    }
}

extension ProductsResponseDTO.ProductDTO {
    func toDomain() -> Product {
        return .init(
            id: Product.Identifier(id),
            name: name,
            description: description,
            price: price,
            stars: stars,
            location: location,
            image: image.toDomain()
        )
    }
}

extension ProductsResponseDTO.ProductImageDTO {
    func toDomain() -> ProductImage {
        return .init(
            url: url,
            blurhash: blurhash,
            width: width,
            height: height
        )
    }
}
