//
//  AddressRequestDTO+Mapping.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

struct AddressRequestDTO: Encodable {
    let contactPersonName: String
    let contactPersonNumber: String
    let address: String
    let addressType: String
    let longitude: String
    let latitude: String
    let defaultShipping: Bool
    
    enum CodingKeys: String, CodingKey {
        case contactPersonName = "contact_person_name"
        case contactPersonNumber = "contact_person_number"
        case address
        case addressType = "address_type"
        case longitude
        case latitude
        case defaultShipping = "default_shipping"
    }
}
