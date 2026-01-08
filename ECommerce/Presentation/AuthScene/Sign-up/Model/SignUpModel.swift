//
//  SignUpModel.swift
//  MyKiot
//
//  Created by wizard.os25 on 24/11/25.
//

import Foundation

// MARK: - Sign Up Request
struct SignUpRequest: Codable {
    let fName: String
    let email: String
    let phone: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case fName = "f_name"
        case email, phone, password
    }
}

// MARK: - Sign Up Response
struct SignUpResponse: Codable {
    let success: Bool
    let message: String
    let data: SignUpData?
    let errors: [APIError]?
    
    enum CodingKeys: String, CodingKey {
        case success, message, data, errors
    }
}

struct SignUpData: Codable {
    let token: String
    let isPhoneVerified: Int
    let phoneVerifyEndUrl: String?
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case token, user
        case isPhoneVerified = "is_phone_verified"
        case phoneVerifyEndUrl = "phone_verify_end_url"
    }
}
