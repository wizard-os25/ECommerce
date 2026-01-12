//
//  AddressController.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation
import UIKit

protocol AddressControllerInput {
    func didTapSave(
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        isDefault: Bool
    )
    func didTapUseCurrentLocation()
}

protocol AddressControllerOutput {
    var isSaveSuccess: Observable<Bool> { get }
    var successMessage: Observable<String?> { get }
    var screenTitle: String { get }
}

typealias AddressController = AddressControllerInput & AddressControllerOutput & EcoController

final class DefaultAddressController: AddressController {
    
    private let createAddressUseCase: CreateAddressUseCase
    private let mainQueue: DispatchQueueType
    private let utilities: Utilities
    
    private var saveTask: Cancellable? { willSet { saveTask?.cancel() } }
    
    // MARK: - OUTPUT
    
    let isSaveSuccess: Observable<Bool> = Observable(false)
    let successMessage: Observable<String?> = Observable(nil)
    let screenTitle = "Add a new address"
    
    // MARK: - EcoController Output (common to all controllers)
    
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<Error?> = Observable(nil)
    let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Navigation Bar Configuration
    
    var navigationBarTitle: String? {
        return self.screenTitle
    }
    
    var navigationBarLeftItem: EcoNavItem? {
        return EcoNavItem.back { [weak self] in
            self?.onNavigationBarLeftItemTap?()
        }
    }
    
    var navigationBarBackground: EcoNavigationBackground {
        return .solid(.white)
    }
    
    var navigationBarBackgroundColor: UIColor? {
        return .white
    }
    
    var navigationBarButtonTintColor: UIColor? {
        return Colors.tokenDark100
    }
    
    var navigationBarInitialHeight: CGFloat {
        return 140
    }
    
    var navigationBarCollapsedHeight: CGFloat {
        return 80
    }
    
    // MARK: - Init
    
    init(
        createAddressUseCase: CreateAddressUseCase,
        utilities: Utilities = Utilities(),
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.createAddressUseCase = createAddressUseCase
        self.utilities = utilities
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func handle(error: Error) {
        let errorMessage = APIErrorParser.parseErrorMessage(from: error)
        let userFriendlyError = NSError(
            domain: "AddressError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: errorMessage]
        )
        self.error.value = userFriendlyError
    }
    
    private func handleSaveSuccess(_ address: Address) {
        isSaveSuccess.value = true
        successMessage.value = "Address saved successfully"
    }
}

// MARK: - INPUT Implementation

extension DefaultAddressController {
    
    func didTapSave(
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        isDefault: Bool
    ) {
        guard !contactPersonName.isEmpty,
              !contactPersonNumber.isEmpty,
              !address.isEmpty else {
            let error = NSError(
                domain: "AddressError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Please fill in all required fields"]
            )
            handle(error: error)
            return
        }
        
        loading.value = true
        error.value = nil
        
        saveTask = createAddressUseCase.execute(
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            address: address,
            addressType: addressType,
            longitude: longitude,
            latitude: latitude
        ) { [weak self] result in
            self?.mainQueue.async {
                self?.loading.value = false
                
                switch result {
                case .success(let address):
                    self?.handleSaveSuccess(address)
                case .failure(let error):
                    self?.handle(error: error)
                }
            }
        }
    }
    
    func didTapUseCurrentLocation() {
        // Logic will be handled later
        // This will trigger location services and update address field
    }
}

// MARK: - EcoController Implementation

extension DefaultAddressController {
    
    func onViewDidLoad() {
        navigationState.value = EcoNavigationState(
            title: navigationBarTitle,
            titleFont: navigationBarTitleFont,
            titleColor: navigationBarTitleColor,
            showsSearch: false,
            searchState: nil,
            leftItem: navigationBarLeftItem,
            rightItems: navigationBarRightItems,
            background: navigationBarBackground,
            backgroundColor: navigationBarBackgroundColor,
            buttonTintColor: navigationBarButtonTintColor,
            height: navigationBarInitialHeight,
            collapsedHeight: navigationBarCollapsedHeight,
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
