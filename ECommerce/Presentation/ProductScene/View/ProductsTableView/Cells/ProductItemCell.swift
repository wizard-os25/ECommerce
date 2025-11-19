//
//  ProductItemCell.swift
//  ExampleMVVM
//
//  Created by wizard.os25 on 14/11/25.
//

import UIKit

final class ProductItemCell: UITableViewCell {
    
    static let height = CGFloat(130)
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var priceLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var productImageView: UIImageView!
    @IBOutlet private var starsLabel: UILabel!
    
    private var items: ProductItemModel?
    
    func fill(with items: ProductItemModel) {
        self.items = items
        
        nameLabel.text = items.name
        priceLabel.text = items.price
        locationLabel.text = items.location
        descriptionLabel.text = items.description
        
        if let stars = items.stars {
            starsLabel.text = String(repeating: "⭐", count: stars)
        } else {
            starsLabel.text = ""
        }
        
        // Load image if URL is available
        if let imageUrl = items.imageUrl {
            loadImage(from: imageUrl)
        } else {
            productImageView.image = nil
        }
    }
    
    private func loadImage(from urlString: String) {
        // For now, we'll use a simple image loading approach
        // In production, you might want to use a proper image loading library
        productImageView.image = nil
        
        // Construct full URL - assuming base URL is http://127.0.0.1:8000
        let baseURL = "http://127.0.0.1:8000"
        let fullURLString: String
        if urlString.hasPrefix("http") {
            fullURLString = urlString
        } else {
            fullURLString = baseURL + urlString
        }
        
        guard let url = URL(string: fullURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.productImageView.image = image
            }
        }.resume()
    }
}
