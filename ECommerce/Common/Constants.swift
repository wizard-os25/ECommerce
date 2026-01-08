//
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
        static let authToken = "auth_token"
        static let userId = "user_id"
        static let userName = "user_name"
        static let userEmail = "user_email"
        static let userPhone = "user_phone"
        static let isPhoneVerified = "is_phone_verified"
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
