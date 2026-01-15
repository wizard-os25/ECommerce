//
//  CheckoutOrderSummaryCell.swift
//  ECommerce
//
//  Created by wizard.os25 on 15/1/26.
//

import UIKit

final class CheckoutOrderSummaryCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order summary"
        label.font = Typography.fontBold16
        label.textColor = Colors.tokenDark100
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtotal"
        label.font = Typography.fontRegular14
        label.textColor = Colors.tokenDark60
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtotalValueLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.fontRegular14
        label.textColor = Colors.tokenDark100
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shippingLabel: UILabel = {
        let label = UILabel()
        label.text = "Shipping"
        label.font = Typography.fontRegular14
        label.textColor = Colors.tokenDark60
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shippingValueLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.fontRegular14
        label.textColor = Colors.tokenDark100
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total"
        label.font = Typography.fontBold16
        label.textColor = Colors.tokenDark100
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.fontBold16
        label.textColor = Colors.tokenDark100
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtotalLabel)
        contentView.addSubview(subtotalValueLabel)
        contentView.addSubview(shippingLabel)
        contentView.addSubview(shippingValueLabel)
        contentView.addSubview(totalLabel)
        contentView.addSubview(totalValueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            subtotalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtotalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            subtotalValueLabel.centerYAnchor.constraint(equalTo: subtotalLabel.centerYAnchor),
            subtotalValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            shippingLabel.topAnchor.constraint(equalTo: subtotalLabel.bottomAnchor, constant: 12),
            shippingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            shippingValueLabel.centerYAnchor.constraint(equalTo: shippingLabel.centerYAnchor),
            shippingValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            totalLabel.topAnchor.constraint(equalTo: shippingLabel.bottomAnchor, constant: 16),
            totalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            totalLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            totalValueLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            totalValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(summary: OrderSummary?) {
        guard let summary = summary else { return }
        
        subtotalValueLabel.text = String(format: "USD %.2f", summary.subtotal)
        shippingValueLabel.text = String(format: "USD %.2f", summary.shippingFee)
        totalValueLabel.text = String(format: "USD %.2f", summary.total)
    }
}
