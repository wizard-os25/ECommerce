//
//  OrderDetailUseCase.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import Foundation

protocol OrderDetailUseCase {
    @discardableResult
    func execute(
        orderId: Int,
        completion: @escaping (Result<OrderDetail, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultOrderDetailUseCase: OrderDetailUseCase {
    
    private let orderDetailRepository: OrderDetailRepository
    
    init(orderDetailRepository: OrderDetailRepository) {
        self.orderDetailRepository = orderDetailRepository
    }
    
    func execute(
        orderId: Int,
        completion: @escaping (Result<OrderDetail, Error>) -> Void
    ) -> Cancellable? {
        return orderDetailRepository.fetchOrderDetail(orderId: orderId, completion: completion)
    }
}
