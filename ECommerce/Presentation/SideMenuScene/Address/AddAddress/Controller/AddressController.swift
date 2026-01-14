//
//  AddressController.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation
import UIKit
import CoreLocation

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
    var onCurrentLocationReceived: ((String, String, String) -> Void)? { get set } // (address, latitude, longitude)
}

typealias AddressController = AddressControllerInput & AddressControllerOutput & EcoController

final class DefaultAddressController: NSObject, AddressController {
    
    private let createAddressUseCase: CreateAddressUseCase
    private let mainQueue: DispatchQueueType
    private let utilities: Utilities
    
    private var saveTask: Cancellable? { willSet { saveTask?.cancel() } }
    
    // MARK: - Location Services
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // MARK: - OUTPUT
    
    let isSaveSuccess: Observable<Bool> = Observable(false)
    let successMessage: Observable<String?> = Observable(nil)
    let screenTitle = "Add a new address"
    var onCurrentLocationReceived: ((String, String, String) -> Void)? // (address, latitude, longitude)
    var onRightBarButtonTap: (() -> Void)?
    
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
    
    var navigationBarRightItems: [EcoNavItem] {
        return [
            EcoNavItem.icon(
                UIImage(systemName: "list.bullet") ?? UIImage(),
                action: { [weak self] in
                    self?.onRightBarButtonTap?()
                }
            )
        ]
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
    
    var navigationBarTitleColor: UIColor? {
        return .black
    }
    
//    var navigationBarInitialHeight: CGFloat {
//        return 140
//    }
//    
//    var navigationBarCollapsedHeight: CGFloat {
//        return 80
//    }
    
    // MARK: - Init
    
    init(
        createAddressUseCase: CreateAddressUseCase,
        utilities: Utilities = Utilities(),
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.createAddressUseCase = createAddressUseCase
        self.utilities = utilities
        self.mainQueue = mainQueue
        super.init()
        setupLocation()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        geocoder.cancelGeocode()
    }
    
    // MARK: - Private Setup
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        // Save location to cache for use in Order screen
        utilities.saveLocation(
            address: address.address,
            latitude: address.latitude,
            longitude: address.longitude
        )
        
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
            latitude: latitude,
            isDefault: isDefault
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
        guard CLLocationManager.locationServicesEnabled() else {
            let error = NSError(
                domain: "AddressController",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Location services are not enabled"]
            )
            handle(error: error)
            return
        }
        
        // Check authorization status - compatible with iOS 13.0+
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Start requesting location
            loading.value = true
            locationManager.requestLocation() // One-time location request
        case .denied, .restricted:
            let error = NSError(
                domain: "AddressController",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Location permission denied. Please enable location services in Settings."]
            )
            handle(error: error)
        @unknown default:
            break
        }
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
            backButtonStyle: .simple, // AddressViewController không cần vòng tròn nhám
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

// MARK: - CLLocationManagerDelegate

extension DefaultAddressController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // User granted permission, request location
            loading.value = true
            locationManager.requestLocation()
        case .denied, .restricted:
            loading.value = false
            let error = NSError(
                domain: "AddressController",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Location permission denied. Please enable location services in Settings."]
            )
            handle(error: error)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            loading.value = false
            return
        }
        
        // Stop updating location (one-time request)
        locationManager.stopUpdatingLocation()
        
        // Reverse geocode to get address
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            self?.mainQueue.async {
                self?.loading.value = false
                
                if let error = error {
                    self?.handle(error: error)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    let noAddressError = NSError(
                        domain: "AddressController",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "Could not determine address for current location"]
                    )
                    self?.handle(error: noAddressError)
                    return
                }
                
                // Build address string from placemark
                var addressComponents: [String] = []
                if let street = placemark.thoroughfare {
                    addressComponents.append(street)
                }
                if let subThoroughfare = placemark.subThoroughfare {
                    addressComponents.append(subThoroughfare)
                }
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }
                if let country = placemark.country {
                    addressComponents.append(country)
                }
                
                let address = addressComponents.joined(separator: ", ")
                let latitude = String(location.coordinate.latitude)
                let longitude = String(location.coordinate.longitude)
                
                // Call callback to update UI
                self?.onCurrentLocationReceived?(address, latitude, longitude)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        mainQueue.async { [weak self] in
            self?.loading.value = false
            self?.handle(error: error)
        }
    }
}
