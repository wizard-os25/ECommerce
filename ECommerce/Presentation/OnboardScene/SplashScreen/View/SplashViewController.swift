//
//  SplashViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 9/1/26.
//

import UIKit

final class SplashViewController: EcoViewController {
    
    // MARK: - UI Components
    
    @IBOutlet private weak var splashImageView: UIImageView?
    @IBOutlet private weak var appNameLabel: UILabel?
    
    private var splashController: SplashController! {
        get { controller as? SplashController }
    }
    
    private weak var coordinatingController: SplashCoordinatingController?
    
    // MARK: - Lifecycle
    
    static func create(
        with splashController: SplashController
    ) -> SplashViewController {
        let viewController = SplashViewController.instantiateViewController()
        viewController.controller = splashController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure view is visible
        view.isHidden = false
    }
    
    // MARK: - Setup
    
    func setCoordinatingController(_ coordinator: SplashCoordinatingController) {
        self.coordinatingController = coordinator
        print("SplashViewController: setCoordinatingController called, coordinator = \(coordinator)")
    }
    
    private func setupViews() {
        // Ensure view has a background color (important for splash screen)
        view.backgroundColor = .white
        
        // Create a label programmatically to ensure something is visible
        let label = UILabel()
        label.text = "ECommerce"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Setup app name label (if outlet is connected)
        appNameLabel?.text = "ECommerce"
        appNameLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        appNameLabel?.textColor = .label
        appNameLabel?.textAlignment = .center
        
        // Setup splash image (if outlet is connected)
        splashImageView?.contentMode = .scaleAspectFit
        splashImageView?.image = UIImage(systemName: "cart.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        
        // Hide navigation bar for splash screen
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Debug: Print to verify view is loaded
        print("SplashViewController: viewDidLoad completed, view.frame = \(view.frame), backgroundColor = \(view.backgroundColor?.description ?? "nil")")
    }
    
    // MARK: - Binding
    
    override func bindCommon() {
        // Bind loading and error, but skip navigation for splash screen
        bindLoading()
        bindError()
        bindSplashSpecific()
    }
    
    override func bindNavigation() {
        // Don't bind navigation for splash screen - no navigation bar needed
    }
    
    override func applyNavigation(_ state: EcoNavigationState) {
        // Don't apply navigation bar for splash screen
    }
    
    private func bindSplashSpecific() {
        print("SplashViewController: bindSplashSpecific - coordinatingController = \(coordinatingController != nil ? "set" : "nil")")
        
        // Observe navigation to Main
        splashController.shouldNavigateToMain.observe(on: self) { [weak self] shouldNavigate in
            print("SplashViewController: shouldNavigateToMain changed to \(shouldNavigate)")
            guard shouldNavigate else { return }
            print("SplashViewController: Navigating to Main")
            self?.navigateToMain()
        }
        
        // Observe navigation to Login
        splashController.shouldNavigateToLogin.observe(on: self) { [weak self] shouldNavigate in
            print("SplashViewController: shouldNavigateToLogin changed to \(shouldNavigate)")
            guard shouldNavigate else { return }
            print("SplashViewController: Navigating to Login")
            self?.navigateToLogin()
        }
        
        // Observe animation state (if needed for UI animations)
        splashController.isAnimating.observe(on: self) { [weak self] isAnimating in
            print("SplashViewController: isAnimating changed to \(isAnimating)")
            // Handle animation state changes if needed
            // For example, fade out splash screen
            if !isAnimating {
                self?.performFadeOutAnimation()
            }
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToMain() {
        print("SplashViewController: navigateToMain called, coordinatingController = \(coordinatingController != nil ? "set" : "nil")")
        guard let coordinator = coordinatingController else {
            print("SplashViewController: ERROR - coordinatingController is nil!")
            return
        }
        coordinator.navigateToMain()
    }
    
    private func navigateToLogin() {
        print("SplashViewController: navigateToLogin called, coordinatingController = \(coordinatingController != nil ? "set" : "nil")")
        guard let coordinator = coordinatingController else {
            print("SplashViewController: ERROR - coordinatingController is nil!")
            return
        }
        coordinator.navigateToLogin()
    }
    
    // MARK: - Animations
    
    private func performFadeOutAnimation() {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.view.alpha = 0.0
            },
            completion: nil
        )
    }
    
    // MARK: - Error Handler Override
    
    override func handleError(_ error: Error?) {
        // Splash screen typically doesn't show errors
        // But if needed, can handle here
        super.handleError(error)
    }
}
