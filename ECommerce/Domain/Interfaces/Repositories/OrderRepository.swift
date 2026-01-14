//
//  OrderRepository.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import Foundation

protocol OrderRepository {
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
