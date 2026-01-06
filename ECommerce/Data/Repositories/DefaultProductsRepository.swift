//
//  DefaultProductsRepository.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import Foundation

final class DefaultProductsRepository {

    private let dataTransferService: DataTransferService
    private let cacheStorage: ProductsResponseStorage?
    private let backgroundQueue: DataTransferDispatchQueue

    init(
        dataTransferService: DataTransferService,
        cacheStorage: ProductsResponseStorage? = nil,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.cacheStorage = cacheStorage
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
        
        guard !task.isCancelled else { return nil }
        
        // 1. Try cache first (non-blocking, async)
        if let cacheStorage = cacheStorage {
            cacheStorage.getResponse(for: requestDTO) { [weak self] result in
                guard !task.isCancelled else { return }
                
                if case .success(let responseDTO?) = result {
                    // Cache hit: Convert to domain and call cached callback
                    let cachedPage = responseDTO.toDomain()
                    self?.backgroundQueue.asyncExecute {
                        cached(cachedPage)
                    }
                }
                // Cache miss: Continue to network (no action needed)
            }
        }
        
        // 2. Fetch from network (always, regardless of cache)
        let endpoint = APIEndpoints.getProducts(with: requestDTO)
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { [weak self] result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success(let responseDTO):
                // Save to cache (async, non-blocking)
                self?.cacheStorage?.save(response: responseDTO, for: requestDTO)
                // Call completion with fresh data
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
