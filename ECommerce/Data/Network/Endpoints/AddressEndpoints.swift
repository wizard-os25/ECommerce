//
//  AddressEndpoints.swift
//  ECommerce
//
//  Created by wizard.os25 on 11/1/26.
//

import Foundation

enum AddressEndpoints {
    
    // MARK: - Create Address
    
    static func createAddress(with requestDTO: AddressRequestDTO) -> Endpoint<AddressResponseDTO> {
        return Endpoint(
            path: "api/v1/customer/addresses",
            method: .post,
            bodyParametersEncodable: requestDTO
        )
    }
}
