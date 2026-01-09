//
//  UserDTO+Mapping.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import Foundation

// MARK: - User DTO (shared between Login, SignUp, and UserInfo)
struct UserDTO: Decodable {
    let id: Int
    let fullName: String
    let email: String
    let phone: String
    let avatarUrl: String?
    let bankAccount: [String]
    let isPhoneVerified: Int
    let orderCount: Int
    let memberSinceDays: Int
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case email
        case phone
        case avatarUrl
        case bankAccount
        case isPhoneVerified
        case orderCount
        case memberSinceDays
        case createdAt
    }
}

// MARK: - Session DTO (shared between Login, SignUp, and RefreshToken)
struct SessionDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case expiresAt
    }
}

// MARK: - Mappings to Domain

extension UserDTO {
    func toDomain() -> User {
        // Try multiple ISO8601 formats for createdAt
        let parseDate: (String) -> Date? = { dateString in
            let dateFormatter1 = ISO8601DateFormatter()
            dateFormatter1.formatOptions = [.withInternetDateTime] // Standard format
            
            let dateFormatter2 = ISO8601DateFormatter()
            dateFormatter2.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // With milliseconds
            
            return dateFormatter1.date(from: dateString) ?? dateFormatter2.date(from: dateString)
        }
        
        return .init(
            id: User.Identifier(id),
            fullName: fullName,
            email: email,
            phone: phone,
            avatarURL: avatarUrl.flatMap { URL(string: $0) },
            bankAccount: bankAccount,
            isPhoneVerified: isPhoneVerified,
            orderCount: orderCount,
            memberSinceDays: memberSinceDays,
            createdAt: createdAt.flatMap { parseDate($0) }
        )
    }
}

extension SessionDTO {
    func toDomain() -> AuthSession {
        // Try multiple ISO8601 formats
        let dateFormatter1 = ISO8601DateFormatter()
        dateFormatter1.formatOptions = [.withInternetDateTime] // Standard format: 2026-02-08T09:49:38Z
        
        let dateFormatter2 = ISO8601DateFormatter()
        dateFormatter2.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // With milliseconds: 2026-02-08T09:49:38.123Z
        
        // Try parsing with standard format first
        var expiredDate: Date?
        if let date = dateFormatter1.date(from: expiresAt) {
            expiredDate = date
        } else if let date = dateFormatter2.date(from: expiresAt) {
            expiredDate = date
        }
        
        guard let expiredDate = expiredDate else {
            // Log error but don't crash - use current date + 1 hour as fallback
            print("Warning: Failed to parse date '\(expiresAt)'. Using fallback date.")
            return .init(
                accessToken: accessToken,
                refreshToken: refreshToken,
                expiredAt: Date().addingTimeInterval(3600) // 1 hour from now
            )
        }
        
        return .init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiredAt: expiredDate
        )
    }
}
