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
    var onSelectProductItem: ((ProductItemModel) -> Void)? { get set }
    var onOpenCamera: (() -> Void)? { get set }
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
    
    // Store original items before filtering
    private var allItems: [ProductItemModel] = []
    
    // MARK: - OUTPUT (Products-specific)
    
    let items: Observable<[ProductItemModel]> = Observable([])
    let query: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    var screenTitle: String { "products".localized() }
    var emptyDataTitle: String { "no_items".localized() }
    var errorTitle: String { "error".localized() }
    
    // AI Search mode flag
    var isAISearchMode: Bool = false
    
    // Flag để đánh dấu khi được push từ màn khác (search hoặc category)
    var isPushedFromOtherScreen: Bool = false
    
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
        // Tăng thêm 48pt khi được push từ màn khác
        return isPushedFromOtherScreen ? 148 : 100
    }
    
    /// Collapsed height of navigation bar when scrolling
    var navigationBarCollapsedHeight: CGFloat {
        // Use default collapsed height (44pt) - standard navigation bar height
        return 80.0
    }
    
    /// Navigation bar button tint color (set to black for right bar items)
    var navigationBarButtonTintColor: UIColor? {
        return .black
    }
    
    /// Navigation bar left item (back button khi được push từ màn khác)
    var navigationBarLeftItem: EcoNavItem? {
        guard isPushedFromOtherScreen else { return nil }
        return EcoNavItem.back { [weak self] in
            self?.didTapBack()
        }
    }
    
    /// Navigation bar right items (camera button for AI Search)
    var navigationBarRightItems: [EcoNavItem] {
        return [
            EcoNavItem.icon(UIImage(systemName: "camera") ?? UIImage(), action: { [weak self] in
                self?.openCamera()
            })
        ]
    }
    
    // Callback for opening card
    var onOpenCard: (() -> Void)?
    
    // Callback for selecting product item
    var onSelectProductItem: ((ProductItemModel) -> Void)?
    
    // Callback for opening camera
    var onOpenCamera: (() -> Void)?
    
    // Callback for back button
    var onBack: (() -> Void)?
    
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
        
        allItems = pages.flatMap { $0.contents }.map(ProductItemModel.init)
        items.value = allItems
    }
    
    /// Load products from ProductPage directly (used for search results)
    func loadProductsFromPage(_ productPage: ProductPage, query: String) {
        productsLoadTask?.cancel()
        resetPages()
        self.query.value = query
        appendPage(productPage)
        loading.value = false
    }
    
    private func resetPages() {
        currentPage = 0
        totalElements = 0
        hasMorePages = false
        pages.removeAll()
        allItems.removeAll()
        items.value.removeAll()
    }
    
    /// Filter items based on AI search labels using NSPredicate-like logic
    /// Bước 1: Chuẩn hóa và token hóa labels để tạo tập từ khóa
    /// Bước 2: Dùng logic tương tự NSPredicate để filter products
    func filterItemsByLabels(_ labels: [(String, Double)]) {
        
        // Log all labels with confidence
        for (index, (label, confidence)) in labels.enumerated() {
        }
        
        
        guard !labels.isEmpty else {
            items.value = allItems
            return
        }
        
        // BƯỚC 1: Chuẩn hóa và token hóa labels để tạo tập từ khóa
        let searchKeywords = normalizeAndTokenizeLabels(labels)
        for (index, keyword) in searchKeywords.enumerated() {
        }
        
        // BƯỚC 2: Filter items với logic tương tự NSPredicate
        // Mỗi keyword phải xuất hiện trong name HOẶC description (OR)
        // Item match nếu có ít nhất một keyword xuất hiện (OR giữa các keywords)
        let filteredItems = allItems.filter { item in
            // Kiểm tra từng keyword: keyword xuất hiện trong name HOẶC description
            return searchKeywords.contains { keyword in
                let nameContains = item.name.lowercased().contains(keyword)
                let descriptionContains = item.description.lowercased().contains(keyword)
                return nameContains || descriptionContains
            }
        }
        
        // Log first few matched items for verification
        if !filteredItems.isEmpty {
            for (index, item) in filteredItems.prefix(5).enumerated() {
            }
            if filteredItems.count > 5 {
            }
        } else {
        }
        
        items.value = filteredItems
    }
    
    /// Bước 1: Chuẩn hóa và token hóa labels để tạo tập từ khóa
    private func normalizeAndTokenizeLabels(_ labels: [(String, Double)]) -> [String] {
        var keywords: Set<String> = []
        
        for (label, _) in labels {
            // Chuẩn hóa: lowercase và trim whitespace
            let normalized = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Token hóa: tách thành các từ (split by spaces, commas, hyphens, etc.)
            let tokens = normalized.components(separatedBy: CharacterSet(charactersIn: " ,-_.()[]{}"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 2 } // Loại bỏ từ quá ngắn (< 3 ký tự)
            
            // Thêm từng token vào tập từ khóa
            for token in tokens {
                keywords.insert(token)
            }
            
            // Nếu label là một từ duy nhất và đủ dài, thêm cả label
            if tokens.count == 1 && normalized.count >= 3 {
                keywords.insert(normalized)
            }
        }
        
        return Array(keywords)
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
        // Cancel any existing task first to prevent cache from different query being loaded
        productsLoadTask?.cancel()
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
        guard hasMorePages, !loading.value else {
            return
        }
        load(productQuery: ProductQuery(query: query.value), loading: false)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else {
            return
        }
        update(productQuery: ProductQuery(query: query))
    }
    
    func didCancelSearch() {
        productsLoadTask?.cancel()
    }
    
    func openCamera() {
        // Mở camera với chế độ .aiSearch
        // Camera sẽ được mở từ ProductsViewController thông qua callback
        if let onOpenCamera = onOpenCamera {
            onOpenCamera()
        } else {
        }
    }
    
    func didSelectItem(at index: Int) {
        guard index >= 0, index < items.value.count else {
            return
        }
        let productItem = items.value[index]
        if let callback = onSelectProductItem {
            callback(productItem)
        } else {
        }
    }
    
    func didTapOpenCard() {
        onOpenCard?()
    }
    
    /// Method để set flag khi được push từ màn khác
    func setPushedFromOtherScreen(_ pushed: Bool) {
        isPushedFromOtherScreen = pushed
        // Update navigation state để reflect changes
        updateNavigationState()
    }
    
    /// Update navigation state với các thay đổi mới nhất
    private func updateNavigationState() {
        var currentState = navigationState.value
        currentState.leftItem = navigationBarLeftItem
        currentState.height = navigationBarInitialHeight
        navigationState.value = currentState
    }
    
    /// Handle back button tap
    private func didTapBack() {
        // Callback để pop navigation controller
        onBack?()
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
        updateNavigationStateOnViewDidLoad()
        
        // Load initial products with default query
        update(productQuery: ProductQuery(query: ""))
    }
    
    private func updateNavigationStateOnViewDidLoad() {
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
            backButtonStyle: .simple, // Use simple style for rightBarItem
            scrollBehavior: navigationBarScrollBehavior
        )
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

