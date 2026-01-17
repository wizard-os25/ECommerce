//
//  OrderDeliveryController.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import Foundation
import UIKit

protocol OrderDeliveryControllerInput {
    func didLoad()
    func didSelectItem(at index: Int)
}

protocol OrderDeliveryControllerOutput {
    var items: Observable<[OrderDeliveryItemModel]> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    
    var onSelectOrderItem: ((OrderDeliveryItemModel) -> Void)? { get set }
}

typealias OrderDeliveryController = OrderDeliveryControllerInput & OrderDeliveryControllerOutput & EcoController

final class DefaultOrderDeliveryController: OrderDeliveryController {
    
    private let orderManageUseCase: OrderManageUseCase
    private let mainQueue: DispatchQueueType
    
    private var allOrders: [OrderManage] = []
    
    // MARK: - OUTPUT
    
    let items: Observable<[OrderDeliveryItemModel]> = Observable([])
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = "Delivery"
    let emptyDataTitle = "No delivery orders"
    let errorTitle = "Error"
    
    var onSelectOrderItem: ((OrderDeliveryItemModel) -> Void)?
    
    // MARK: - EcoController Output
    
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<Error?> = Observable(nil)
    let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Init
    
    init(
        orderManageUseCase: OrderManageUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.orderManageUseCase = orderManageUseCase
        self.mainQueue = mainQueue
    }
    
    // MARK: - Navigation Bar Configuration
    
    var navigationBarTitle: String? {
        return screenTitle
    }
    
    var navigationBarShowsSearch: Bool {
        return false
    }
    
    var navigationBarBackground: EcoNavigationBackground {
        return .solid(.white)
    }
    
    var navigationBarBackgroundColor: UIColor? {
        return .white
    }
    
    var navigationBarTitleColor: UIColor? {
        return .black
    }
    
    var navigationBarInitialHeight: CGFloat {
        return 140
    }
    
    var navigationBarButtonTintColor: UIColor? {
        return .black
    }
    
    // MARK: - Input
    
    func onViewDidLoad() {
        updateNavigationState()
    }
    
    func onViewWillAppear() {}
    func onViewDidDisappear() {}
    
    func didLoad() {
        loadOrders()
    }
    
    func didSelectItem(at index: Int) {
        guard index >= 0 && index < items.value.count else { return }
        let item = items.value[index]
        onSelectOrderItem?(item)
    }
    
    // MARK: - Private
    
    private func loadOrders() {
        loading.value = true
        error.value = nil
        
        orderManageUseCase.execute { [weak self] result in
            guard let self = self else { return }
            
            self.mainQueue.async(execute: {
                self.loading.value = false
                
                switch result {
                case .success(let orders):
                    self.allOrders = orders
                    self.filterDeliveryOrders()
                case .failure(let err):
                    self.error.value = err
                }
            })
        }
    }
    
    private func filterDeliveryOrders() {
        let deliveryOrders = allOrders.filter { $0.orderStatus == "out_for_delivery" }
        items.value = deliveryOrders.map { OrderDeliveryItemModel(orderManage: $0) }
    }
    
    func updateOrders(_ orders: [OrderManage]) {
        allOrders = orders
        filterDeliveryOrders()
    }
    
    private func updateNavigationState() {
        var state = EcoNavigationState()
        state.title = screenTitle
        state.background = navigationBarBackground
        state.backgroundColor = navigationBarBackgroundColor
        state.titleColor = navigationBarTitleColor
        state.height = navigationBarInitialHeight
        state.buttonTintColor = navigationBarButtonTintColor
        navigationState.value = state
    }
}
