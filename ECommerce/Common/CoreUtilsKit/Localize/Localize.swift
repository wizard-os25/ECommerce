//
//  Localize.swift
//  ECommerce
//
//  Created by wizard.os25 on 17/11/25.
//

import Foundation

/// Internal current language key
private let CurrentLanguageKey = "CurrentLanguageKey"

/// Default language. Vietnamese. If Vietnamese is unavailable defaults to base localization.
private let DefaultLanguage = "vi"

/// Base bundle as fallback.
let BaseBundle = "Base"

/// Name for language change notification
extension Notification.Name {
    static let LanguageChangeNotification = Notification.Name(rawValue: "LanguageChangeNotification")
}

// MARK: - Language Setting Functions
open class Localize: NSObject {
    
    /// List available languages
    /// - Returns: Array of available languages
    open class func availableLanguages(_ excludeBase: Bool = false) -> [String] {
        var availableLanguages = Bundle.main.localizations
        
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base"), excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        
        return availableLanguages
    }
    
    /// Current language
    /// - Returns: The current language
    open class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: CurrentLanguageKey) as? String {
            return currentLanguage
        }
        return self.defaultLanguage()
    }
    
    /// Change the current language
    /// - Parameter language: Desired language
    open class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : self.defaultLanguage()
        if selectedLanguage != currentLanguage() {
            UserDefaults.standard.set(selectedLanguage, forKey: CurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .LanguageChangeNotification, object: nil)
        }
    }
    
    /// Default language
    /// - Returns: The app's default language
    open class func defaultLanguage() -> String {
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return DefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if availableLanguages.contains(preferredLanguage) {
            return preferredLanguage
        } else {
            return DefaultLanguage
        }
    }
}

// MARK: - Localize from TableName and Bundle
public extension String {
    /// Localize from TableName and Bundle
    /// - Parameters:
    ///   - tableName: The receiver's string table to search. If tableName is `nil` or is an empty string, the method attempts to use `Localizable.strings`.
    ///   - bundle: The receiver's bundle to search. If bundle is `nil`, the method attempts to use main bundle.
    /// - Returns: The localized string
    func localized(using tableName: String? = nil, in bundle: Bundle? = nil) -> String {
        let bundle: Bundle = bundle ?? .main
        if let path = bundle.path(forResource: Localize.currentLanguage(), ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        } else if let path = bundle.path(forResource: BaseBundle, ofType: "lproj"),
                  let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
}

