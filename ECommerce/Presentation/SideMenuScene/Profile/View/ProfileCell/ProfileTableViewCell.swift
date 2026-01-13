//
//  ProfileTableViewCell.swift
//  ECommerce
//
//  Created by wizard.os25 on 13/1/26.
//

import UIKit

final class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet private var profileTitleLabel: UILabel!
    @IBOutlet private var profileSubtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileTitleLabel.text = nil
        profileSubtitleLabel.text = nil
    }
    
    // MARK: - Configuration
    
    func fill(with title: String, subtitle: String?) {
        profileTitleLabel.text = title
        profileSubtitleLabel.text = subtitle
        profileSubtitleLabel.isHidden = subtitle == nil || subtitle?.isEmpty == true
    }
    
    // MARK: - Private
    
    private func setupViews() {
        // Title configuration
        profileTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        profileTitleLabel.textColor = .label
        
        // Subtitle configuration
        profileSubtitleLabel.font = UIFont.systemFont(ofSize: 14)
        profileSubtitleLabel.textColor = .gray
        
        // Cell configuration
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }
}
