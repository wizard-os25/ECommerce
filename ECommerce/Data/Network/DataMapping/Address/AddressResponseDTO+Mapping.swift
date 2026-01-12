//
//  AddressResponseDTO+Mapping.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

// MARK: - API Response Wrapper
struct AddressAPIResponseWrapper: Decodable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: AddressResponseDTOInternal?
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case success
        case message
        case data
    }
}

// MARK: - Internal DTO for decoding nested "data" structure
struct AddressResponseDTOInternal: Decodable {
    let id: Int
    let userId: Int
    let contactPersonName: String
    let contactPersonNumber: String
    let address: String
    let addressType: String
    let longitude: String
    let latitude: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case contactPersonName = "contact_person_name"
        case contactPersonNumber = "contact_person_number"
        case address
        case addressType = "address_type"
        case longitude
        case latitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - AddressResponseDTO - main DTO used by Endpoint<AddressResponseDTO>
struct AddressResponseDTO: Decodable {
    let id: Int
    let userId: Int
    let contactPersonName: String
    let contactPersonNumber: String
    let address: String
    let addressType: String
    let longitude: String
    let latitude: String
    let createdAt: String
    let updatedAt: String
    
    // Init from decoder (API response)
    init(from decoder: Decoder) throws {
        // Decode the wrapper first to extract "data" key
        let wrapper = try AddressAPIResponseWrapper(from: decoder)
        guard let data = wrapper.data else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Address response data is nil"
                )
            )
        }
        
        // Extract values from data
        self.id = data.id
        self.userId = data.userId
        self.contactPersonName = data.contactPersonName
        self.contactPersonNumber = data.contactPersonNumber
        self.address = data.address
        self.addressType = data.addressType
        self.longitude = data.longitude
        self.latitude = data.latitude
        self.createdAt = data.createdAt
        self.updatedAt = data.updatedAt
    }
    
    // Init for manual creation
    init(
        id: Int,
        userId: Int,
        contactPersonName: String,
        contactPersonNumber: String,
        address: String,
        addressType: String,
        longitude: String,
        latitude: String,
        createdAt: String,
        updatedAt: String
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
    }
}

// MARK: - Mappings to Domain

extension AddressResponseDTO {
    func toDomain() -> Address {
        // Parse dates from ISO8601 string format
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return Address(
            id: id,
            userId: userId,
            contactPersonName: contactPersonName,
            contactPersonNumber: contactPersonNumber,
            address: address,
            addressType: addressType,
            longitude: longitude,
            latitude: latitude,
            createdAt: dateFormatter.date(from: createdAt),
            updatedAt: dateFormatter.date(from: updatedAt),
            isDefault: false // API doesn't return this, will be set separately if needed
        )
    }
}
