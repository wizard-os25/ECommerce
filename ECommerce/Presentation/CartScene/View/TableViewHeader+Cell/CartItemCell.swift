//
//  CartItemsCell.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 19/6/25.
//

import UIKit

class CartItemCell: UITableViewCell {
    
    @IBOutlet weak var onChooseButton: UIButton!
    @IBOutlet weak var cartItemImageView: UIImageView!
    @IBOutlet weak var cartItemTitleLabel: UILabel!
    @IBOutlet weak var cartItemDescLabel: UILabel!
    @IBOutlet weak var cartItemAmountLabel: UILabel!
    
    @IBOutlet weak var cartItemDeleteButton: UIButton!
    @IBOutlet weak var cartItemTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
