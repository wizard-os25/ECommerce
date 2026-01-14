
//  Constants.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 3/6/25.
//

import Foundation

enum Constants {

    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKey {
        static let isUserLoggedIn = "isLogin"
        
        // Session keys
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let expiresAt = "expires_at"
        
        // Legacy token key (for backward compatibility)
        static let authToken = "auth_token"
        
        // User keys
        static let userId = "user_id"
        static let userName = "user_name"
        static let userEmail = "user_email"
        static let userPhone = "user_phone"
        static let userAvatarURL = "user_avatar_url"
        static let isPhoneVerified = "is_phone_verified"
        static let orderCount = "order_count"
        static let memberSinceDays = "member_since_days"
        
        // Location cache keys
        static let cachedLatitude = "cached_latitude"
        static let cachedLongitude = "cached_longitude"
        static let cachedAddress = "cached_address"
    }

    // MARK: - Language
    
    static func getLanguage() -> String {
        let languageCode = Locale.current.languageCode
        if languageCode == "vi" || languageCode == "vi-VN" {
            return "vi"
        }
        return "vi" // fallback vẫn là "vi"
    }
}

