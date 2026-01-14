//
//  DefaultOrderRepository.swift
//  ECommerce
//
//  Created by wizard.os25 on 14/1/26.
//

import Foundation

final class DefaultOrderRepository {
    
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
}

extension DefaultOrderRepository: OrderRepository {
    
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
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let cartDTOs = cart.map { CartItemDTO(id: $0.id, quantity: $0.quantity) }
        let requestDTO = PlaceOrderRequestDTO(
            orderAmount: orderAmount,
            cart: cartDTOs,
            address: address,
            longitude: longitude,
            latitude: latitude,
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            orderNote: orderNote
        )
        
        let endpoint = APIEndpoints.placeOrder(with: requestDTO)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.data.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
