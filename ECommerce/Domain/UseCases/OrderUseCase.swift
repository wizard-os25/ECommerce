//
//  OrderUseCase.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import Foundation

protocol OrderUseCase {
    func placeOrder(
        orderAmount: Double,
        cart: [CartItem],
        address: String,
        longitude: String,
        latitude: String,
        contactPersonName: String,
        contactPersonNumber: String,
        orderNote: String?,
        completion: @escaping (Result<Order, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultOrderUseCase: OrderUseCase {
    
    private let orderRepository: OrderRepository
    
    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }
    
    func placeOrder(
        orderAmount: Double,
        cart: [CartItem],
        address: String,
        longitude: String,
        latitude: String,
        contactPersonName: String,
        contactPersonNumber: String,
        orderNote: String?,
        completion: @escaping (Result<Order, Error>) -> Void
    ) -> Cancellable? {
        return orderRepository.placeOrder(
            orderAmount: orderAmount,
            cart: cart,
            address: address,
            longitude: longitude,
            latitude: latitude,
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            orderNote: orderNote,
            completion: completion
        )
    }
}
