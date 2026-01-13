//
//  LoginController.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import Foundation
import UIKit

protocol LoginControllerInput {
    func didTapLogin(phone: String, password: String)
}

protocol LoginControllerOutput {
    var isLoginSuccess: Observable<Bool> { get }
    var successMessage: Observable<String?> { get }
    var screenTitle: String { get }
}

typealias LoginController = LoginControllerInput & LoginControllerOutput & EcoController

final class DefaultLoginController: LoginController {
    
    private let loginUseCase: LoginUseCase
    private let mainQueue: DispatchQueueType
    private let utilities: Utilities
    
    private var loginTask: Cancellable? { willSet { loginTask?.cancel() } }
    
    // MARK: - OUTPUT
    
    let isLoginSuccess: Observable<Bool> = Observable(false)
    let successMessage: Observable<String?> = Observable(nil)
    let screenTitle = NSLocalizedString("Login", comment: "")
    
    // MARK: - EcoController Output (common to all controllers)
    
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<Error?> = Observable(nil)
    let navigationState: Observable<EcoNavigationState> = Observable(.init())
    
    // MARK: - Navigation Bar Configuration
    
    var navigationBarTitle: String? {
        return self.screenTitle
    }
    
    var navigationBarLeftItem: EcoNavItem? {
        return EcoNavItem.back { [weak self] in
            self?.onNavigationBarLeftItemTap?()
        }
    }
    
    // MARK: - Init
    
    init(
        loginUseCase: LoginUseCase,
        utilities: Utilities = Utilities(),
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.loginUseCase = loginUseCase
        self.utilities = utilities
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func handle(error: Error) {
        // Parse error message from API response
        let errorMessage = APIErrorParser.parseErrorMessage(from: error)
        let userFriendlyError = NSError(
            domain: "LoginError",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: errorMessage]
        )
        self.error.value = userFriendlyError
    }
    
    private func handleLoginSuccess(_ authResult: AuthResult) {
        print("========== LOGIN SUCCESS - SAVING DATA ==========")
        print("📝 Saving session info:")
        print("   - Access Token: \(authResult.session.accessToken.prefix(20))...")
        print("   - Refresh Token: \(authResult.session.refreshToken.prefix(20))...")
        print("   - Expires At: \(authResult.session.expiredAt)")
        
        print("👤 Saving user info:")
        print("   - User ID: \(authResult.user.id)")
        print("   - Full Name: \(authResult.user.fullName)")
        print("   - Email: \(authResult.user.email)")
        print("   - Phone: \(authResult.user.phone)")
        print("   - Avatar URL: \(authResult.user.avatarURL?.absoluteString ?? "nil")")
        print("   - Order Count: \(authResult.user.orderCount)")
        print("   - Member Since Days: \(authResult.user.memberSinceDays)")
        
        // Save session and user info to UserDefaults
        utilities.saveSession(
            accessToken: authResult.session.accessToken,
            refreshToken: authResult.session.refreshToken,
            expiresAt: authResult.session.expiredAt
        )
        utilities.saveUser(user: authResult.user)
        utilities.saveLogging(true)
        
        print("✅ Login data saved successfully")
        print("================================================")
        
        // Update success state
        isLoginSuccess.value = true
        
        // Trigger success message - View will observe and show alert using default alertable
        successMessage.value = "Login successful!"
    }
}

// MARK: - INPUT. View event methods

extension DefaultLoginController {
    
    func didTapLogin(phone: String, password: String) {
        // Validation errors
        if phone.isEmpty || password.isEmpty {
            error.value = NSError(domain: "LoginValidation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Please fill in all fields"])
            return
        }
        
        if !isValidPhone(phone) {
            error.value = NSError(domain: "LoginValidation", code: 2, userInfo: [NSLocalizedDescriptionKey: "Please enter a valid phone number"])
            return
        }
        
        if password.count < 6 {
            error.value = NSError(domain: "LoginValidation", code: 3, userInfo: [NSLocalizedDescriptionKey: "Password must be at least 6 characters"])
            return
        }
        
        loading.value = true
        error.value = nil
        
        loginTask = loginUseCase.execute(
            phone: phone,
            password: password
        ) { [weak self] result in
            self?.mainQueue.async {
                self?.loading.value = false
                switch result {
                case .success(let authResult):
                    self?.handleLoginSuccess(authResult)
                case .failure(let error):
                    self?.handle(error: error)
                }
            }
        }
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,11}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}

// MARK: - EcoController Implementation

extension DefaultLoginController {
    
    var onNavigationBarLeftItemTap: (() -> Void)? {
        { [weak self] in
            // Handle back button tap - navigation will be handled by coordinator
        }
    }
    
    func onViewDidLoad() {
        // Initialize navigation state
        let leftItem = navigationBarLeftItem
        print("🔵 [LoginController] onViewDidLoad - Setting navigation state")
        print("   - Title: \(navigationBarTitle ?? "nil")")
        print("   - LeftItem: \(leftItem != nil ? "EXISTS" : "nil")")
        print("   - RightItems count: \(navigationBarRightItems.count)")
        print("   - Background: \(navigationBarBackground)")
        print("   - ButtonTintColor: \(navigationBarButtonTintColor?.description ?? "nil")")
        
        navigationState.value = EcoNavigationState(
            title: navigationBarTitle,
            titleFont: navigationBarTitleFont,
            titleColor: navigationBarTitleColor,
            showsSearch: navigationBarShowsSearch,
            searchState: nil,
            leftItem: leftItem,
            rightItems: navigationBarRightItems,
            background: navigationBarBackground,
            backgroundColor: navigationBarBackgroundColor,
            buttonTintColor: navigationBarButtonTintColor,
            height: navigationBarInitialHeight,
            collapsedHeight: navigationBarCollapsedHeight,
            scrollBehavior: navigationBarScrollBehavior
        )
        print("✅ [LoginController] Navigation state set")
    }
    
    func onViewWillAppear() {
        // Handle view will appear if needed
    }
    
    func onViewDidDisappear() {
        // Handle view did disappear if needed
    }
}