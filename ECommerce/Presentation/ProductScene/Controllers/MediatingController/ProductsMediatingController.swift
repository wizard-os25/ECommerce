//
//  ProductsMediatingController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import Foundation

struct ProductsMediatorActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showProductDetails: (ProductItemModel) -> Void
}

protocol ProductsMediatingControllerInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func didSelectItem(at index: Int)
}

protocol ProductsMediatingControllerOutput {
    var items: Observable<[ProductItemModel]> { get }
    var loading: Observable<Bool> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
}

typealias ProductsMediatingController = ProductsMediatingControllerInput & ProductsMediatingControllerOutput

final class DefaultProductsMediatingController: ProductsMediatingController {
    
    private let productsRepository: ProductsRepository
    private let mainQueue: DispatchQueueType
    
    private let actions: ProductsMediatorActions?

    
    var currentPage: Int = 0
    var totalElements: Int = 0
    var hasMorePages: Bool = false
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    let pageSize: Int = 20
    
    private var pages: [ProductPage] = []
    private var productsLoadTask: Cancellable? { willSet { productsLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    
    let items: Observable<[ProductItemModel]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Products", comment: "")
    let emptyDataTitle = NSLocalizedString("No products found", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    // MARK: - Init
    
    init(
        productsRepository: ProductsRepository,
        mainQueue: DispatchQueueType = DispatchQueue.main,
        actions: ProductsMediatorActions? = nil

    ) {
        self.productsRepository = productsRepository
        self.mainQueue = mainQueue
        self.actions = actions
    }
    
    // MARK: - Private
    
    private func appendPage(_ productPage: ProductPage) {
        currentPage = productPage.page
        totalElements = productPage.totalElements
        hasMorePages = productPage.hasMore
        
        pages = pages
            .filter { $0.page != productPage.page }
            + [productPage]
        
        items.value = pages.flatMap { $0.contents }.map(ProductItemModel.init)
    }
    
    private func resetPages() {
        currentPage = 0
        totalElements = 0
        hasMorePages = false
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func load(productQuery: ProductQuery, loading: Bool) {
        self.loading.value = loading
        query.value = productQuery.query
        
        productsLoadTask = productsRepository.fetchProductsList(
            query: productQuery,
            page: nextPage,
            pageSize: pageSize,
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = false
                }
            }
        )
    }
    
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading products", comment: "")
    }
    
    private func update(productQuery: ProductQuery) {
        resetPages()
        load(productQuery: productQuery, loading: true)
    }
}

// MARK: - INPUT. View event methods

extension DefaultProductsMediatingController {
    
    func viewDidLoad() {
        // Load initial products with default query
        update(productQuery: ProductQuery(query: "13"))
    }
    
    func didLoadNextPage() {
        guard hasMorePages, !loading.value else { return }
        load(productQuery: ProductQuery(query: query.value), loading: false)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(productQuery: ProductQuery(query: query))
    }
    
    func didCancelSearch() {
        productsLoadTask?.cancel()
    }
    
    func didSelectItem(at index: Int) {
        // Handle item selection if needed
    }
}

// MARK: - Private

private extension Array where Element == ProductPage {
    var products: [Product] { flatMap { $0.contents } }
}
