//
//  RecommendedItemCell.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 19/6/25.
//

//import UIKit
//
//class RecommendedItemCell: UITableViewCell {
//    
//    @IBOutlet weak var recommendedCollectionView: UICollectionView!
//    @IBOutlet weak var recommendedCollectionViewHeightConstraint: NSLayoutConstraint!
//    
//    private var items: [Product] = []
//    let layout = PinterestLayout()
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        
//        self.layout.numberOfColumns = 2
//        self.layout.delegate = self
//        self.recommendedCollectionView.collectionViewLayout = self.layout
//                
//        self.recommendedCollectionView.delegate = self
//        self.recommendedCollectionView.dataSource = self
//        self.recommendedCollectionView.isScrollEnabled = false
//        self.recommendedCollectionView.register(cell: PinterestCell.self)
//        //self.recommendedCollectionView.reloadData()
//
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        self.layout.invalidateLayout()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
//    
//    func configure(with product: [Product]) {
//        self.items = product
//        
//        DispatchQueue.main.async {
//            self.recommendedCollectionView.reloadData()
//            self.layout.invalidateLayout()
//                    self.recommendedCollectionView.layoutIfNeeded()
//                    
//                    let contentHeight = self.layout.collectionViewContentSize.height
//                    self.recommendedCollectionViewHeightConstraint.constant = contentHeight
//            
//            if let tableView = self.superview as? UITableView {
//                tableView.beginUpdates()
//                tableView.endUpdates()
//            }
//        }
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//extension RecommendedItemCell: UICollectionViewDelegate {}
//
//// MARK: - UICollectionViewDataSource
//extension RecommendedItemCell: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.items.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let item = self.items[indexPath.item]
//        let cell: PinterestCell = collectionView.dequeueReusableCell(at: indexPath)
//        cell.configure(with: item)
//        return cell
//    }
//}
//
//// MARK: - PinterestLayoutDelegate
//extension RecommendedItemCell: PinterestLayoutDelegate {
//    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
//
//        let product = items[indexPath.item]
////        let imageWidth = CGFloat(product.imageWidth ?? 1)
////        let imageHeight = CGFloat(product.imageHeight ?? 1)
//
//        guard imageWidth > 0 else { return 180 } // fallback nếu dữ liệu lỗi
//        
//        // 👉 Tính chiều rộng thực tế của item trong layout
//        let layout = collectionView.collectionViewLayout as? PinterestLayout
//        let columnWidth = (collectionView.bounds.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right) / CGFloat(layout?.numberOfColumns ?? 2)
//        
////        let scaledHeight = imageHeight * columnWidth / imageWidth
//        return scaledHeight
//    }
//}
//
