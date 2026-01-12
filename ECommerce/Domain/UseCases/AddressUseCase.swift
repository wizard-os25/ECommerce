//
//  AddressUseCase.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

protocol CreateAddressUseCase {
    @discardableResult
    func execute(
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        isDefault: Bool,
        completion: @escaping (Result<Address, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateAddressUseCase: CreateAddressUseCase {
    
    private let addressRepository: AddressRepository
    
    init(addressRepository: AddressRepository) {
        self.addressRepository = addressRepository
    }
    
    func execute(
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        isDefault: Bool,
        completion: @escaping (Result<Address, Error>) -> Void
    ) -> Cancellable? {
        return addressRepository.createAddress(
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            address: address,
            addressType: addressType,
            longitude: longitude,
            latitude: latitude,
            isDefault: isDefault,
            completion: completion
        )
    }
}
