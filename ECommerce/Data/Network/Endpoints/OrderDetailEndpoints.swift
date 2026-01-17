//
//  OrderDetailEndpoints.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import Foundation

enum OrderDetailEndpoints {
    
    // MARK: - Get Order Detail
    
    static func getOrderDetail(orderId: Int) -> Endpoint<OrderDetailResponseDTO> {
        return Endpoint(
            path: "api/v1/orders/\(orderId)",
            method: .get
        )
    }
}
