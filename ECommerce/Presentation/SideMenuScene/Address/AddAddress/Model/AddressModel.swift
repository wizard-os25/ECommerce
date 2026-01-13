//
//  AddressModel.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

// MARK: - Address Form Model (Presentation Layer)
// Only contains information needed for the Address screen form

public struct AddressFormModel {
    public var contactPersonName: String
    public var contactPersonNumber: String
    public var address: String
    public var addressType: String
    public var longitude: String
    public var latitude: String
    public var isDefault: Bool
    
    public init(
        contactPersonName: String = "",
        contactPersonNumber: String = "",
        address: String = "",
        addressType: String = "home",
        longitude: String = "",
        latitude: String = "",
        isDefault: Bool = false
    ) {
        self.contactPersonName = contactPersonName
        self.contactPersonNumber = contactPersonNumber
        self.address = address
        self.addressType = addressType
        self.longitude = longitude
        self.latitude = latitude
        self.isDefault = isDefault
    }
    
    public var isValid: Bool {
        return !contactPersonName.isEmpty &&
               !contactPersonNumber.isEmpty &&
               !address.isEmpty &&
               !longitude.isEmpty &&
               !latitude.isEmpty
    }
}
