//
//  Order.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import Foundation

public struct CartItem {
    public let id: Int
    public let quantity: Int
    
    public init(id: Int, quantity: Int) {
        self.id = id
        self.quantity = quantity
    }
}

public struct Order {
    public let orderId: Int
    public let totalAmount: Double
    public let taxAmount: Double
    
    public init(orderId: Int, totalAmount: Double, taxAmount: Double) {
        self.orderId = orderId
        self.totalAmount = totalAmount
        self.taxAmount = taxAmount
    }
}
