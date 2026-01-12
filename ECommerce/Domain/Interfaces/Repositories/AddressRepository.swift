//
//  AddressRepository.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

protocol AddressRepository {
    @discardableResult
    func createAddress(
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
