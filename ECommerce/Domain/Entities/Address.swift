//
//  Address.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

public struct Address: Identifiable {
    public typealias Identifier = Int
    
    public let id: Identifier
    public let userId: Int
    public let contactPersonName: String
    public let contactPersonNumber: String
    public let address: String
    public let addressType: String
    public let longitude: String
    public let latitude: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public let isDefault: Bool
    
    public init(
        id: Identifier,
        userId: Int,
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.userId = userId
        self.contactPersonName = contactPersonName
        self.contactPersonNumber = contactPersonNumber
        self.address = address
        self.addressType = addressType
        self.longitude = longitude
        self.latitude = latitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDefault = isDefault
    }
}
