//
//  OrderDetailOtherInfoCell.swift
//  ECommerce
//
//  Created by wizard.os25 on 16/1/26.
//

import UIKit

final class OrderDetailOtherInfoCell: UITableViewCell {
    
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var orderNoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func fill(with orderDetail: OrderDetail) {
        // Shipping Fee
        shippingFeeLabel?.text = "Shipping Fee: \(Int(orderDetail.shippingFee).formattedWithSeparator) VND"
        
        // Payment Method
        paymentMethodLabel?.text = "Payment Method: \(orderDetail.formattedPaymentMethod)"
        
        // Confirmed
        if let confirmed = orderDetail.confirmed {
            confirmedLabel?.text = "Confirmed: \(orderDetail.formatDate(confirmed))"
            confirmedLabel?.isHidden = false
        } else {
            confirmedLabel?.isHidden = true
        }
        
        // Order Note
        if let orderNote = orderDetail.orderNote, !orderNote.isEmpty {
            orderNoteLabel?.text = "Order Note: \(orderNote)"
            orderNoteLabel?.isHidden = false
        } else {
            orderNoteLabel?.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        shippingFeeLabel?.text = nil
        paymentMethodLabel?.text = nil
        confirmedLabel?.text = nil
        confirmedLabel?.isHidden = false
        orderNoteLabel?.text = nil
        orderNoteLabel?.isHidden = false
    }
}
