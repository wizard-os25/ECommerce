//
//  OrderDTOs+Mapping.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import Foundation

// MARK: - Place Order Request

struct PlaceOrderRequestDTO: Encodable {
    let orderAmount: Double
    let cart: [CartItemDTO]
    let address: String
    let longitude: String
    let latitude: String
    let contactPersonName: String
    let contactPersonNumber: String
    let orderNote: String?
    
    enum CodingKeys: String, CodingKey {
        case orderAmount = "order_amount"
        case cart
        case address
        case longitude
        case latitude
        case contactPersonName = "contact_person_name"
        case contactPersonNumber = "contact_person_number"
        case orderNote = "order_note"
    }
}

struct CartItemDTO: Encodable {
    let id: Int
    let quantity: Int
}

// MARK: - Place Order Response

struct PlaceOrderResponseDTO: Decodable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: PlaceOrderDataDTO
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case success
        case message
        case data
    }
}

struct PlaceOrderDataDTO: Decodable {
    let orderId: Int
    let totalAmount: Double
    let taxAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case totalAmount = "total_amount"
        case taxAmount = "tax_amount"
    }
}

// MARK: - Mappings to Domain

extension PlaceOrderDataDTO {
    func toDomain() -> Order {
        return Order(
            orderId: orderId,
            totalAmount: totalAmount,
            taxAmount: taxAmount
        )
    }
}
