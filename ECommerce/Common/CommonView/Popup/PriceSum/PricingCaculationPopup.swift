//
//  PricingCaculationPopup.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 19/6/25.
//

import UIKit

class PricingCaculationPopup: UIView {

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titlePricingLabel: UILabel!
    @IBOutlet weak var orderBreakdownLabel: UILabel!
    @IBOutlet weak var orderBreakdownValueLabel: UILabel!
    @IBOutlet weak var shippingLabel: UILabel!
    @IBOutlet weak var shippingValueLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var subTotalValue: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    @IBAction func didTapClosePopup(_ sender: Any) {
        self.dismiss()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PricingCaculationPopup", owner: self, options: nil)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(self.contentView)
    }
    
    func show(in parentView: UIView) {
        
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0),
            self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0),
            self.heightAnchor.constraint(equalToConstant: 444)
        ])
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

