//
//  DefaultProductsRepository.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import Foundation

final class DefaultProductsRepository {

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

extension DefaultProductsRepository: ProductsRepository {
    func fetchProductsList(
        query: ProductQuery,
        page: Int,
        pageSize: Int,
        cached: @escaping (ProductPage) -> Void,
        completion: @escaping (Result<ProductPage, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = ProductsRequestDTO(query: query.query, page: page, pageSize: pageSize)
        let task = RepositoryTask()
        
        // For now, we don't have cache, so we skip cached callback
        guard !task.isCancelled else { return nil }
        
        let endpoint = APIEndpoints.getProducts(with: requestDTO)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
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
