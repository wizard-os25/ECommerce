//
//  Login.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 3/6/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Phone Number"
        textField.keyboardType = .phonePad
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đăng ký tài khoản"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        // Thêm underline để làm rõ đây là link
        let attributedString = NSMutableAttributedString(string: "Đăng ký tài khoản")
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Login"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Large title configuration
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(phoneTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(loginButton)
        contentView.addSubview(errorLabel)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(signUpLabel)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Phone TextField
            phoneTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Error Label
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign Up Label
            signUpLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 24),
            signUpLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
            signUpLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            signUpLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Sign Up Label tap gesture
        let signUpTapGesture = UITapGestureRecognizer(target: self, action: #selector(signUpLabelTapped))
        signUpLabel.addGestureRecognizer(signUpTapGesture)
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Cho phép tap vào label vẫn hoạt động
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Sign Up Action
    @objc private func signUpLabelTapped(_ gesture: UITapGestureRecognizer) {
        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.signUpLabel.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.signUpLabel.alpha = 1.0
            }
        }
        
        // ✅ Điều hướng đến màn hình SignUp (RegisterController) - Present modal
//        let registerVC = Storyboard.instantiateTab(of: RegisterController.self, context: nil)
//        let navController = UINavigationController(rootViewController: registerVC)
//        
//        // Có thể thêm close button nếu muốn
//        registerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .cancel,
//            target: self,
//            action: #selector(dismissSignUp)
//        )
//        
//        self.present(navController, animated: true)
    }
    
    @objc private func dismissSignUp() {
        dismiss(animated: true)
    }
    
    // MARK: - Validation
    private func validateInputs() -> (isValid: Bool, errorMessage: String?) {
        guard let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else {
            return (false, "Please enter your phone number")
        }
        
        guard phone.count >= 10 else {
            return (false, "Phone number must be at least 10 digits")
        }
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !password.isEmpty else {
            return (false, "Please enter your password")
        }
        
        guard password.count >= 6 else {
            return (false, "Password must be at least 6 characters")
        }
        
        return (true, nil)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped() {
        view.endEditing(true)
        hideError()
        
        // Validate inputs
        let validation = validateInputs()
        guard validation.isValid else {
            showError(validation.errorMessage ?? "Invalid input")
            return
        }
        
        // Start loading
        setLoading(true)
        
        // Call API
//        Task {
//            do {
//                let phone = phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//                let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//                
//                let response = try await NetworkManager.shared.login(phone: phone, password: password)
//                
//                await MainActor.run {
//                    self.setLoading(false)
//                    
//                    if response.success, let data = response.data {
//                        // Save user info và login state qua Utilities
//                        Utilities().saveUserInfo(userData: data)
//                        Utilities().saveLogging(true)
//                        
//                        // Navigate to TabBar
//                        let tabBarVC = Storyboard.instantiateTab(of: TabBarController.self)
//                        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
//                        
//                        UIView.transition(with: window,
//                                        duration: 0.3,
//                                        options: .transitionCrossDissolve,
//                                        animations: {
//                            window.rootViewController = tabBarVC
//                        }, completion: nil)
//                    } else {
//                        // Show error from API
//                        let errorMessage = response.errors?.first?.message ?? response.message
//                        self.showError(errorMessage ?? "Login failed")
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    self.setLoading(false)
//                    self.showError("Network error. Please try again.")
//                    print("❌ Login error: \(error)")
//                }
//            }
//        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        loginButton.alpha = isLoading ? 0.6 : 1.0
        
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
