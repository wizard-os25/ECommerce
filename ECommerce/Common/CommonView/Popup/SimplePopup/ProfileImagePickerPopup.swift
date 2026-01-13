//
//  ProfileImagePickerPopup.swift
//  ECommerce
//
//  Created by wizard.os25 on 13/1/26.
//

import UIKit

final class ProfileImagePickerPopup: UIView {
    
    @IBOutlet private weak var chooseFromPhotosLabel: UILabel!
    @IBOutlet private weak var openCameraLabel: UILabel!
    @IBOutlet private weak var cancelLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    
    private var dimmedView: UIView?
    
    var onChooseFromPhotos: (() -> Void)?
    var onOpenCamera: (() -> Void)?
    var onCancel: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Setup
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProfileImagePickerPopup", owner: self, options: nil)
        guard let contentView = contentView else {
            fatalError("ProfileImagePickerPopup.xib doesn't exist or contentView outlet is not connected")
        }
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        // Setup views after loading from XIB
        setupViews()
    }
    
    private func setupViews() {
        // Configure labels
        chooseFromPhotosLabel.text = "Choose on Photos"
        chooseFromPhotosLabel.font = UIFont.systemFont(ofSize: 16)
        chooseFromPhotosLabel.textColor = .label
        chooseFromPhotosLabel.textAlignment = .center
        
        openCameraLabel.text = "Open camera"
        openCameraLabel.font = UIFont.systemFont(ofSize: 16)
        openCameraLabel.textColor = .label
        openCameraLabel.textAlignment = .center
        
        cancelLabel.text = "Cancel"
        cancelLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelLabel.textColor = .systemRed
        cancelLabel.textAlignment = .center
        
        // Setup tap gestures
        let chooseFromPhotosTap = UITapGestureRecognizer(target: self, action: #selector(handleChooseFromPhotos))
        chooseFromPhotosLabel.isUserInteractionEnabled = true
        chooseFromPhotosLabel.addGestureRecognizer(chooseFromPhotosTap)
        
        let openCameraTap = UITapGestureRecognizer(target: self, action: #selector(handleOpenCamera))
        openCameraLabel.isUserInteractionEnabled = true
        openCameraLabel.addGestureRecognizer(openCameraTap)
        
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(handleCancel))
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.addGestureRecognizer(cancelTap)
        
        // Configure popup appearance
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
    
    // MARK: - Actions
    
    @objc private func handleChooseFromPhotos() {
        onChooseFromPhotos?()
        dismiss()
    }
    
    @objc private func handleOpenCamera() {
        onOpenCamera?()
        dismiss()
    }
    
    @objc private func handleCancel() {
        onCancel?()
        dismiss()
    }
    
    // MARK: - Show/Dismiss
    
    func show(in parentView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        // Create dimmed background
        let dimmed = UIView(frame: parentView.bounds)
        dimmed.translatesAutoresizingMaskIntoConstraints = false
        dimmed.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        dimmedView = dimmed
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dimmed.addGestureRecognizer(tap)
        
        parentView.addSubview(dimmed)
        parentView.addSubview(self)
        
        NSLayoutConstraint.activate([
            // Dimmed view constraints
            dimmed.topAnchor.constraint(equalTo: parentView.topAnchor),
            dimmed.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            dimmed.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            dimmed.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            
            // Popup constraints - bottom of screen, height 280
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            heightAnchor.constraint(equalToConstant: 280)
        ])
        
        // Animate in
        alpha = 0
        dimmed.alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 280)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            dimmed.alpha = 1
            self.transform = .identity
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.dimmedView?.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 280)
        }, completion: { _ in
            self.dimmedView?.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
}
