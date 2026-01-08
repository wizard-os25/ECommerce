//
//  LoginModel.swift
//  MyKiot
//
//  Created by wizard.os25 on 24/11/25.
//

import Foundation

// MARK: - Login Request
struct LoginRequest: Codable {
    let phone: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case phone, password
    }
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: LoginData?
    let errors: [APIError]?
    
    enum CodingKeys: String, CodingKey {
        case success, message, data, errors
    }
}

struct LoginData: Codable {
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

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
}

struct APIError: Codable {
    let code: String?
    let message: String?
}
