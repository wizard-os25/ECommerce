//
//  Utilities.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 3/6/25.
//

import Foundation

class Utilities: NSObject {
    
    let defaults = UserDefaults.standard
    
    // MARK: - Login State
    
    /// Set User login state
    func saveLogging(_ isLogin: Bool) {
        print("💾 [Utilities] Saving login state:")
        print("   - Is Logged In: \(isLogin) -> Key: \(Constants.UserDefaultsKey.isUserLoggedIn)")
        defaults.set(isLogin, forKey: Constants.UserDefaultsKey.isUserLoggedIn)
        
        // Verify saved value
        let savedLoginState = defaults.bool(forKey: Constants.UserDefaultsKey.isUserLoggedIn)
        print("✅ [Utilities] Login state saved - Verification: \(savedLoginState)")
    }
    
    /// Get User login state
    func isLoggedIn() -> Bool {
        return defaults.bool(forKey: Constants.UserDefaultsKey.isUserLoggedIn)
    }
    
    // MARK: - Session Management
    
    /// Save session info (accessToken, refreshToken, expiresAt)
    func saveSession(accessToken: String, refreshToken: String, expiresAt: Date) {
        print("💾 [Utilities] Saving session to UserDefaults:")
        print("   - Access Token Key: \(Constants.UserDefaultsKey.accessToken)")
        print("   - Refresh Token Key: \(Constants.UserDefaultsKey.refreshToken)")
        print("   - Expires At Key: \(Constants.UserDefaultsKey.expiresAt)")
        print("   - Expires At Value: \(expiresAt)")
        
        defaults.set(accessToken, forKey: Constants.UserDefaultsKey.accessToken)
        defaults.set(refreshToken, forKey: Constants.UserDefaultsKey.refreshToken)
        defaults.set(expiresAt, forKey: Constants.UserDefaultsKey.expiresAt)
        
        // Verify saved values
        let savedAccessToken = defaults.string(forKey: Constants.UserDefaultsKey.accessToken)
        let savedRefreshToken = defaults.string(forKey: Constants.UserDefaultsKey.refreshToken)
        let savedExpiresAt = defaults.object(forKey: Constants.UserDefaultsKey.expiresAt) as? Date
        
        print("✅ [Utilities] Session saved - Verification:")
        print("   - Access Token saved: \(savedAccessToken != nil ? "YES (\(savedAccessToken!.prefix(20))...)" : "NO")")
        print("   - Refresh Token saved: \(savedRefreshToken != nil ? "YES (\(savedRefreshToken!.prefix(20))...)" : "NO")")
        print("   - Expires At saved: \(savedExpiresAt != nil ? "YES (\(savedExpiresAt!))" : "NO")")
    }
    
    /// Get access token
    func getAccessToken() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.accessToken)
    }
    
    /// Get refresh token
    func getRefreshToken() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.refreshToken)
    }
    
    /// Get expires at date
    func getExpiresAt() -> Date? {
        return defaults.object(forKey: Constants.UserDefaultsKey.expiresAt) as? Date
    }
    
    /// Check if session is expired
    func isSessionExpired() -> Bool {
        guard let expiresAt = getExpiresAt() else {
            return true
        }
        return Date() >= expiresAt
    }
    
    // MARK: - User Info Management
    
    /// Save user info
    func saveUser(user: User) {
        print("💾 [Utilities] Saving user info to UserDefaults:")
        print("   - User ID: \(user.id) -> Key: \(Constants.UserDefaultsKey.userId)")
        print("   - Full Name: \(user.fullName) -> Key: \(Constants.UserDefaultsKey.userName)")
        print("   - Email: \(user.email) -> Key: \(Constants.UserDefaultsKey.userEmail)")
        print("   - Phone: \(user.phone) -> Key: \(Constants.UserDefaultsKey.userPhone)")
        print("   - Avatar URL: \(user.avatarURL?.absoluteString ?? "nil") -> Key: \(Constants.UserDefaultsKey.userAvatarURL)")
        print("   - Is Phone Verified: \(user.isPhoneVerified) -> Key: \(Constants.UserDefaultsKey.isPhoneVerified)")
        print("   - Order Count: \(user.orderCount) -> Key: \(Constants.UserDefaultsKey.orderCount)")
        print("   - Member Since Days: \(user.memberSinceDays) -> Key: \(Constants.UserDefaultsKey.memberSinceDays)")
        
        defaults.set(user.id, forKey: Constants.UserDefaultsKey.userId)
        defaults.set(user.fullName, forKey: Constants.UserDefaultsKey.userName)
        defaults.set(user.email, forKey: Constants.UserDefaultsKey.userEmail)
        defaults.set(user.phone, forKey: Constants.UserDefaultsKey.userPhone)
        defaults.set(user.avatarURL?.absoluteString, forKey: Constants.UserDefaultsKey.userAvatarURL)
        defaults.set(user.isPhoneVerified, forKey: Constants.UserDefaultsKey.isPhoneVerified)
        defaults.set(user.orderCount, forKey: Constants.UserDefaultsKey.orderCount)
        defaults.set(user.memberSinceDays, forKey: Constants.UserDefaultsKey.memberSinceDays)
        
        // Verify saved values
        let savedUserId = defaults.integer(forKey: Constants.UserDefaultsKey.userId)
        let savedUserName = defaults.string(forKey: Constants.UserDefaultsKey.userName)
        let savedUserEmail = defaults.string(forKey: Constants.UserDefaultsKey.userEmail)
        let savedUserPhone = defaults.string(forKey: Constants.UserDefaultsKey.userPhone)
        
        print("✅ [Utilities] User info saved - Verification:")
        print("   - User ID saved: \(savedUserId > 0 ? "YES (\(savedUserId))" : "NO")")
        print("   - Full Name saved: \(savedUserName != nil ? "YES (\(savedUserName!))" : "NO")")
        print("   - Email saved: \(savedUserEmail != nil ? "YES (\(savedUserEmail!))" : "NO")")
        print("   - Phone saved: \(savedUserPhone != nil ? "YES (\(savedUserPhone!))" : "NO")")
    }
    
    /// Get user ID
    func getUserId() -> Int? {
        let userId = defaults.integer(forKey: Constants.UserDefaultsKey.userId)
        return userId > 0 ? userId : nil
    }
    
    /// Get user full name
    func getUserFullName() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.userName)
    }
    
    /// Get user email
    func getUserEmail() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.userEmail)
    }
    
    /// Get user phone
    func getUserPhone() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.userPhone)
    }
    
    /// Get user avatar URL
    func getUserAvatarURL() -> URL? {
        guard let urlString = defaults.string(forKey: Constants.UserDefaultsKey.userAvatarURL) else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// Get user info as User object
    func getUserInfo() -> User? {
        guard let id = getUserId(),
              let fullName = getUserFullName(),
              let email = getUserEmail(),
              let phone = getUserPhone() else {
            return nil
        }
        return User(
            id: id,
            fullName: fullName,
            email: email,
            phone: phone,
            avatarURL: getUserAvatarURL(),
            bankAccount: [],
            isPhoneVerified: defaults.integer(forKey: Constants.UserDefaultsKey.isPhoneVerified),
            orderCount: defaults.integer(forKey: Constants.UserDefaultsKey.orderCount),
            memberSinceDays: defaults.integer(forKey: Constants.UserDefaultsKey.memberSinceDays),
            createdAt: nil
        )
    }
    
    /// Check if phone is verified
    func isPhoneVerified() -> Bool {
        return defaults.integer(forKey: Constants.UserDefaultsKey.isPhoneVerified) == 1
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    /// Get auth token (legacy - returns accessToken)
    func getAuthToken() -> String? {
        return getAccessToken()
    }
    
    // MARK: - Logout
    
    /// Clear all user info and logout
    func logout() {
        print("========== LOGOUT - CLEARING DATA ==========")
        
        // Log current values before clearing
        print("📋 Current stored data before logout:")
        print("   - Is Logged In: \(defaults.bool(forKey: Constants.UserDefaultsKey.isUserLoggedIn))")
        print("   - Access Token: \(defaults.string(forKey: Constants.UserDefaultsKey.accessToken) != nil ? "EXISTS" : "nil")")
        print("   - Refresh Token: \(defaults.string(forKey: Constants.UserDefaultsKey.refreshToken) != nil ? "EXISTS" : "nil")")
        print("   - Expires At: \(defaults.object(forKey: Constants.UserDefaultsKey.expiresAt) != nil ? "EXISTS" : "nil")")
        print("   - User ID: \(defaults.integer(forKey: Constants.UserDefaultsKey.userId))")
        print("   - User Name: \(defaults.string(forKey: Constants.UserDefaultsKey.userName) ?? "nil")")
        print("   - User Email: \(defaults.string(forKey: Constants.UserDefaultsKey.userEmail) ?? "nil")")
        print("   - User Phone: \(defaults.string(forKey: Constants.UserDefaultsKey.userPhone) ?? "nil")")
        
        // Clear login state
        print("🗑️ Clearing login state...")
        saveLogging(false)
        
        // Clear session
        print("🗑️ Clearing session data...")
        defaults.removeObject(forKey: Constants.UserDefaultsKey.accessToken)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.refreshToken)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.expiresAt)
        print("   ✅ Removed: accessToken, refreshToken, expiresAt")
        
        // Clear user info
        print("🗑️ Clearing user info...")
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userId)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userName)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userEmail)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userPhone)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userAvatarURL)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.isPhoneVerified)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.orderCount)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.memberSinceDays)
        print("   ✅ Removed: userId, userName, userEmail, userPhone, userAvatarURL, isPhoneVerified, orderCount, memberSinceDays")
        
        // Legacy support
        defaults.removeObject(forKey: Constants.UserDefaultsKey.authToken)
        print("   ✅ Removed: authToken (legacy)")
        
        // Verify all cleared
        print("✅ Logout completed - Verification:")
        print("   - Is Logged In: \(defaults.bool(forKey: Constants.UserDefaultsKey.isUserLoggedIn))")
        print("   - Access Token: \(defaults.string(forKey: Constants.UserDefaultsKey.accessToken) != nil ? "STILL EXISTS ❌" : "CLEARED ✅")")
        print("   - Refresh Token: \(defaults.string(forKey: Constants.UserDefaultsKey.refreshToken) != nil ? "STILL EXISTS ❌" : "CLEARED ✅")")
        print("   - User ID: \(defaults.integer(forKey: Constants.UserDefaultsKey.userId) > 0 ? "STILL EXISTS ❌" : "CLEARED ✅")")
        print("============================================")
    }
}

//@objc public static func shouldShowForceUpdate(minVersionSupport: String) -> Bool {
//    let appVersion = HelperFunction.appVersion()
//    if !minVersionSupport.isEmpty && HelperFunction.compareVersions(appVersion, minVersionSupport) == .lessThan {
//        return true
//    } else {
//        return false
//    }
//}
//}
//public let adjustDomain = Bundle.main.bundleIdentifier?.contains("staging") == true ? "vtmoney.go.link/" :
//                          Bundle.main.bundleIdentifier?.contains("uat") == true ? "vtmoneyuat.go.link/" : "viettelmoney.go.link/"
