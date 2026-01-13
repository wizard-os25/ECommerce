//
//  LocationListResponseDTO+Mapping.swift
//  ECommerce
//
//  Created by wizard.os25 on 13/1/26.
//

import Foundation

// MARK: - API Response Wrapper
struct LocationListAPIResponseWrapper: Decodable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: [LocationListResponseDTOInternal]
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case success
        case message
        case data
    }
}

// MARK: - Internal DTO for decoding nested "data" structure
struct LocationListResponseDTOInternal: Decodable {
    let id: Int
    let addressType: String
    let contactPersonNumber: String
    let address: String
    let latitude: String
    let zoneId: Int
    let longitude: String
    let userId: Int
    let contactPersonName: String
    let createdAt: String
    let updatedAt: String
    let defaultShipping: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case addressType = "address_type"
        case contactPersonNumber = "contact_person_number"
        case address
        case latitude
        case zoneId = "zone_id"
        case longitude
        case userId = "user_id"
        case contactPersonName = "contact_person_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case defaultShipping = "default_shipping"
    }
}

// MARK: - LocationListResponseDTO - main DTO used by Endpoint<LocationListResponseDTO>
struct LocationListResponseDTO: Decodable {
    let addresses: [LocationListAddressDTO]
    
    // Init from decoder (API response)
    init(from decoder: Decoder) throws {
        // Decode the wrapper first to extract "data" array
        let wrapper = try LocationListAPIResponseWrapper(from: decoder)
        
        // Convert array of internal DTOs to array of address DTOs
        self.addresses = wrapper.data.map { internalDTO in
            LocationListAddressDTO(
                id: internalDTO.id,
                addressType: internalDTO.addressType,
                contactPersonNumber: internalDTO.contactPersonNumber,
                address: internalDTO.address,
                latitude: internalDTO.latitude,
                zoneId: internalDTO.zoneId,
                longitude: internalDTO.longitude,
                userId: internalDTO.userId,
                contactPersonName: internalDTO.contactPersonName,
                createdAt: internalDTO.createdAt,
                updatedAt: internalDTO.updatedAt,
                defaultShipping: internalDTO.defaultShipping
            )
        }
    }
    
    // Init for manual creation
    init(addresses: [LocationListAddressDTO]) {
        self.addresses = addresses
    }
}


// MARK: - LocationListAddressDTO
struct LocationListAddressDTO: Decodable {
    let id: Int
    let addressType: String
    let contactPersonNumber: String
    let address: String
    let latitude: String
    let zoneId: Int
    let longitude: String
    let userId: Int
    let contactPersonName: String
    let createdAt: String
    let updatedAt: String
    let defaultShipping: Bool
}

// MARK: - Mappings to Domain
extension LocationListAddressDTO {
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
            isDefault: defaultShipping
        )
    }
}
