//
//  ProductsMediatingController.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import Foundation
import UIKit

protocol ProductsControllerInput {
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func didSelectItem(at index: Int)
}

protocol ProductsControllerOutput {
    // Products-specific outputs (EcoController already provides: loading, error, navigationState)
    var items: Observable<[ProductItemModel]> { get }
    var query: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    
    // Callbacks
    var onOpenCard: (() -> Void)? { get set }
}

typealias ProductsController = ProductsControllerInput & ProductsControllerOutput & EcoController

final class DefaultProductsController: ProductsController {
    
    private let productsRepository: ProductsRepository
    private let mainQueue: DispatchQueueType
    
    var currentPage: Int = 0
    var totalElements: Int = 0
    var hasMorePages: Bool = false
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    let pageSize: Int = 20
    
    private var pages: [ProductPage] = []
    private var productsLoadTask: Cancellable? { willSet { productsLoadTask?.cancel() } }
    
    // MARK: - OUTPUT (Products-specific)
    
    let items: Observable<[ProductItemModel]> = Observable([])
    let query: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Products", comment: "")
    let emptyDataTitle = NSLocalizedString("No products found", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    // MARK: - Navigation Bar Configuration
    
    /// Navigation bar title (override default to use screenTitle)
    var navigationBarTitle: String? {
        return self.screenTitle
    }
    
    /// Whether to show search field in navigation bar (override default to enable search for Products scene)
    var navigationBarShowsSearch: Bool {
        return true
    }
    
    /// Search field state configuration (override default to use "Search products" placeholder)
    var navigationBarSearchState: EcoSearchState {
        return EcoSearchState(
            text: "",
            placeholder: "Search products",
            isEditing: false,
            showsClearButton: true,
            showsCameraButton: true,
            height: navigationBarSearchFieldHeight,
            backgroundColor: navigationBarSearchFieldBackgroundColor,
            borderWidth: navigationBarSearchFieldBorderWidth,
            borderColor: navigationBarSearchFieldBorderColor
        )
    }
    
    /// Navigation bar scroll behavior (override default to enable collapse with search)
    var navigationBarScrollBehavior: EcoNavigationScrollBehavior {
        return .collapseWithSearch
    }
    
    /// Initial height of navigation bar for Products scene
    var navigationBarInitialHeight: CGFloat {
        return 120
    }
    
    /// Collapsed height of navigation bar when scrolling
    var navigationBarCollapsedHeight: CGFloat {
        return 80
    }
    
    /// Navigation bar button tint color (set to black for right bar items)
    var navigationBarButtonTintColor: UIColor? {
        return .black
    }
    
    /// Navigation bar right items (add card button)
    var navigationBarRightItems: [EcoNavItem] {
        return [
            EcoNavItem.icon(UIImage(systemName: "rectangle.bottomthird.inset.filled") ?? UIImage(), action: { [weak self] in
                self?.didTapOpenCard()
            })
        ]
    }
    
    // Callback for opening card
    var onOpenCard: (() -> Void)?
    
    // MARK: - EcoController Output (common to all controllers)
    
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<Error?> = Observable(nil)
    let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Init
    
    init(
        productsRepository: ProductsRepository,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.productsRepository = productsRepository
        self.mainQueue = mainQueue
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
        self.error.value = error
    }
    
    private func update(productQuery: ProductQuery) {
        resetPages()
        load(productQuery: productQuery, loading: true)
    }
    
    private func updateSearchState(text: String) {
        // Không update navigationState.value để tránh trigger render lại toàn bộ navigation bar
        // Chỉ update text trực tiếp trong searchTextField thông qua callback
        // Callback sẽ được gọi từ searchTextField.onTextChange
        // Không cần update state ở đây vì text đã được update trực tiếp trong textField
    }
}

// MARK: - INPUT. View event methods

extension DefaultProductsController {
    
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
    
    func openCamera() {
        // TODO: Implement camera opening logic
        // Example: Present UIImagePickerController or custom camera view
        print("Camera button tapped - implement camera opening logic here")
    }
    
    func didSelectItem(at index: Int) {
        // Handle item selection if needed
    }
    
    func didTapOpenCard() {
        onOpenCard?()
    }
}

    // MARK: - EcoController Implementation

extension DefaultProductsController {
    
    // MARK: - Navigation Bar Callbacks
    
    var onNavigationBarSearchTextChange: ((String) -> Void)? {
        { [weak self] text in
            self?.updateSearchState(text: text)
        }
    }
    
    var onNavigationBarSearchSubmit: ((String) -> Void)? {
        { [weak self] text in
            guard let self = self, !text.isEmpty else { return }
            self.didSearch(query: text)
        }
    }
    
    var onNavigationBarSearchClear: (() -> Void)? {
        { [weak self] in
            guard let self = self else { return }
            self.updateSearchState(text: "")
            self.didCancelSearch()
        }
    }
    
    var onNavigationBarCameraTap: (() -> Void)? {
        { [weak self] in
            self?.openCamera()
        }
    }
    
    func onViewDidLoad() {
        // Initialize navigation state using customizable properties
        // All navigation bar properties can be customized by overriding the computed properties above
        navigationState.value = EcoNavigationState(
            title: navigationBarTitle,
            titleFont: navigationBarTitleFont,
            titleColor: navigationBarTitleColor,
            showsSearch: navigationBarShowsSearch,
            searchState: navigationBarShowsSearch ? navigationBarSearchState : nil,
            leftItem: navigationBarLeftItem,
            rightItems: navigationBarRightItems,
            background: navigationBarBackground,
            backgroundColor: navigationBarBackgroundColor,
            buttonTintColor: navigationBarButtonTintColor,
            height: navigationBarInitialHeight,
            collapsedHeight: navigationBarCollapsedHeight,
            scrollBehavior: navigationBarScrollBehavior
        )
        
        // Load initial products with default query
        update(productQuery: ProductQuery(query: "13"))
    }
    
    func onViewWillAppear() {
        // Handle view will appear if needed
    }
    
    func onViewDidDisappear() {
        // Handle view did disappear if needed
    }
}

// MARK: - Private

private extension Array where Element == ProductPage {
    var products: [Product] { flatMap { $0.contents } }
}

