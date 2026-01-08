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
        defaults.set(isLogin, forKey: Constants.UserDefaultsKey.isUserLoggedIn)
    }
    
    /// Get User login state
    func isLoggedIn() -> Bool {
        return defaults.bool(forKey: Constants.UserDefaultsKey.isUserLoggedIn)
    }
    
    // MARK: - User Info Management
    
    /// Save user info after login/register
    /// - Parameter userData: LoginData or SignUpData from API response
    func saveUserInfo(userData: LoginData) {
        defaults.set(userData.token, forKey: Constants.UserDefaultsKey.authToken)
        defaults.set(userData.user.id, forKey: Constants.UserDefaultsKey.userId)
        defaults.set(userData.user.name, forKey: Constants.UserDefaultsKey.userName)
        defaults.set(userData.user.email, forKey: Constants.UserDefaultsKey.userEmail)
        defaults.set(userData.user.phone, forKey: Constants.UserDefaultsKey.userPhone)
        defaults.set(userData.isPhoneVerified, forKey: Constants.UserDefaultsKey.isPhoneVerified)
    }
    
    /// Save user info from SignUpData
    func saveUserInfo(userData: SignUpData) {
        defaults.set(userData.token, forKey: Constants.UserDefaultsKey.authToken)
        defaults.set(userData.user.id, forKey: Constants.UserDefaultsKey.userId)
        defaults.set(userData.user.name, forKey: Constants.UserDefaultsKey.userName)
        defaults.set(userData.user.email, forKey: Constants.UserDefaultsKey.userEmail)
        defaults.set(userData.user.phone, forKey: Constants.UserDefaultsKey.userPhone)
        defaults.set(userData.isPhoneVerified, forKey: Constants.UserDefaultsKey.isPhoneVerified)
    }
    
    /// Get auth token
    func getAuthToken() -> String? {
        return defaults.string(forKey: Constants.UserDefaultsKey.authToken)
    }
    
    /// Get user ID
    func getUserId() -> Int? {
        let userId = defaults.integer(forKey: Constants.UserDefaultsKey.userId)
        return userId > 0 ? userId : nil
    }
    
    /// Get user name
    func getUserName() -> String? {
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
    
    /// Get user info as User object
    func getUserInfo() -> User? {
        guard let id = getUserId(),
              let name = getUserName(),
              let email = getUserEmail(),
              let phone = getUserPhone() else {
            return nil
        }
        return User(id: id, name: name, email: email, phone: phone)
    }
    
    /// Check if phone is verified
    func isPhoneVerified() -> Bool {
        return defaults.integer(forKey: Constants.UserDefaultsKey.isPhoneVerified) == 1
    }
    
    // MARK: - Logout
    
    /// Clear all user info and logout
    func logout() {
        // Clear login state
        saveLogging(false)
        
        // Clear user info
        defaults.removeObject(forKey: Constants.UserDefaultsKey.authToken)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userId)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userName)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userEmail)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.userPhone)
        defaults.removeObject(forKey: Constants.UserDefaultsKey.isPhoneVerified)
    }
}
