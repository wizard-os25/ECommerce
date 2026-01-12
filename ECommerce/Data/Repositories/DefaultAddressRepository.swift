//
//  DefaultAddressRepository.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

final class DefaultAddressRepository {
    
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

extension DefaultAddressRepository: AddressRepository {
    func createAddress(
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        completion: @escaping (Result<Address, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = AddressRequestDTO(
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            address: address,
            addressType: addressType,
            longitude: longitude,
            latitude: latitude
        )
        let task = RepositoryTask()
        
        guard !task.isCancelled else { return nil }
        
        let endpoint = AddressEndpoints.createAddress(with: requestDTO)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
