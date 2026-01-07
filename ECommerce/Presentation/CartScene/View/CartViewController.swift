//
//  CartViewController.swift
//  ECommerce
//
//  Created by wizard.os25 on 7/1/26.
//

//import UIKit
//
//class CartViewController: UIViewController {
//    
//    @IBOutlet weak var cartTableView: UITableView!
//    @IBOutlet weak var pricingCalculationView: UIView!
//    
//    private var dataSource: UITableViewDiffableDataSource<ProductList, Product>?
//    
//    private var sectionsMap: [CartSection: ProductList] = [:]
//    private let sectionDisplayOrder: [CartSection] = [.cartItem, .guaranteed, .recommended]
//
//    private var sortedSections: [ProductList] {
//        self.sectionDisplayOrder.compactMap { self.sectionsMap[$0] }
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        self.pricingCalculationView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        self.pricingCalculationView.layer.shadowOpacity = 0.33
//        self.pricingCalculationView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        self.pricingCalculationView.layer.shadowRadius = 4
//        self.pricingCalculationView.layer.masksToBounds = false
//        
//        self.cartTableView.register(GuaranteedHeaderView.nib, forHeaderFooterViewReuseIdentifier: GuaranteedHeaderView.identifier)
//        self.cartTableView.register(TableSectionHeader.nib, forHeaderFooterViewReuseIdentifier: TableSectionHeader.identifier)
//        
//        self.cartTableView.register(CartItemCell.nib, forCellReuseIdentifier: CartItemCell.identifier)
//        self.cartTableView.register(RecommendedItemCell.nib, forCellReuseIdentifier: RecommendedItemCell.identifier)
//        
//        self.cartTableView.delegate = self
//        self.cartTableView.backgroundColor = .systemBackground
//        self.cartTableView.separatorStyle = .none
//        self.cartTableView.contentInsetAdjustmentBehavior = .never
//        self.cartTableView.sectionHeaderHeight = UITableView.automaticDimension
//        self.cartTableView.sectionFooterHeight = 0.0
//        self.cartTableView.rowHeight = UITableView.automaticDimension
//        self.cartTableView.estimatedRowHeight = 300
//        
//        self.createDataSource()
//        self.loadData()
//    }
//    
//    @IBAction func didTapShowDetailPricingBtn(_ sender: Any) {
//        let popupView = PricingCaculationPopup()
//        popupView.show(in: self.navigationController?.view ?? view)
//        self.navigationController?.view?.addSubview(popupView)
//    }
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//    
//    private func createDataSource() {
//        self.dataSource = UITableViewDiffableDataSource<ProductList, Product>(tableView: self.cartTableView) { [weak self] tableView, indexPath, product in
//            guard let self = self,
//                  let section = self.dataSource?.snapshot().sectionIdentifiers[safe: indexPath.section] ,
//                    let sectionType = CartSection(rawValue: section.typeId)
//            else {
//                assertionFailure("⚠️ Không tìm thấy section cho indexPath: \(indexPath)")
//                return nil
//            }
//
//                switch sectionType {
//                    
//                case .cartItem:
//                    let isEmpty = section.products.isEmpty
//
//                    let cell = isEmpty
//                    ? tableView.configure(EmptyCell.self, with: product, for: indexPath)
//                    : tableView.configure(CartItemCell.self, with: product, for: indexPath)
//                    
//                    /// imple action in cell here
//
//                    return cell
//
//                case .recommended:
//                    return tableView.configTBCell(RecommendedItemCell.self, with: section.products, for: indexPath)
//                    
//
//            default:
//                return UITableViewCell()
//            }
//        }
//    }
//    
//    private func reloadAllSections() {
//        var snapshot = NSDiffableDataSourceSnapshot<ProductList, Product>()
//        for section in sortedSections {
//            snapshot.appendSections([section])
//            snapshot.appendItems(section.products, toSection: section)
//        }
//        
//        self.dataSource?.apply(snapshot, animatingDifferences: true)
//    }
//    
//    private func reloadSection(_ section: ProductList) {
//        DispatchQueue.main.async {
//            guard var snapshot = self.dataSource?.snapshot() else { return }
//            let isRecommended = CartSection(rawValue: section.typeId) == .recommended
//
//
//            if snapshot.sectionIdentifiers.contains(section) {
//                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
//                snapshot.appendItems(section.products, toSection: section)
//            } else {
//                snapshot.appendSections([section])
//                if isRecommended, let first = section.products.first {
//                                snapshot.appendItems([first], toSection: section)
//                            } else {
//                                snapshot.appendItems(section.products, toSection: section)
//                            }
//            }
//
//            self.dataSource?.apply(snapshot, animatingDifferences: true)
//        }
//    }
//    
//    func loadData() {
//        Task {
//            let typeOrder: [CartSection] = [.cartItem, .guaranteed, .recommended]
//            var results: [Int: ProductList] = [:]
//            
//            await withTaskGroup(of: (Int, ProductList?).self) { group in
//                for type in typeOrder {
//                    group.addTask {
//                        // Chỉ gọi API nếu endpoint không rỗng
//                        guard !type.endpoint.isEmpty else {
//                            return (type.rawValue, nil)
//                        }
//                        // Sử dụng fetchProductList với pagination mặc định
//                        let result = try? await NetworkManager.shared.fetchProductList(
//                            typeId: type.rawValue,
//                            page: 0,
//                            pageSize: 15
//                        )
//                        return (type.rawValue, result)
//                    }
//                }
//                
//                for await (typeId, section) in group {
//                    if let section = section {
//                        results[typeId] = section
//                    }
//                }
//            }
//            
//            for type in typeOrder {
//                if let section = results[type.rawValue] {
//                    DispatchQueue.main.async {
//                        self.sectionsMap[type] = section
//                        self.reloadSection(section)
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//extension CartViewController: UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.sortedSections.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let section = self.dataSource?.snapshot().sectionIdentifiers[safe: indexPath.section],
//              let sectionType = CartSection(rawValue: section.typeId)
//        else { return 0 }
//        
//        return sectionType.rowHeight(
//            cartItemCount: section.products.count,
//            recommendedItemCount: section.products.count
//        )
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard let section = dataSource?.snapshot().sectionIdentifiers[safe: section],
//              let sectionType = CartSection(rawValue: section.typeId),
//              sectionType.hasHeader
//        else { return 0 }
//        
//        return UITableView.automaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNonzeroMagnitude
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return nil
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let sectionIdentifiers = dataSource?.snapshot().sectionIdentifiers[safe: section],
//              let sectionType = CartSection(rawValue: sectionIdentifiers.typeId)
//        else { return nil }
//        switch sectionType {
//        case .cartItem:
//            return nil
//        case .guaranteed:
//            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: GuaranteedHeaderView.identifier) as? GuaranteedHeaderView
//            header?.guaranteedTitleLabel.text = sectionType.title
//            return header
//        case .recommended:
//            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableSectionHeader.identifier) as? TableSectionHeader
//            header?.titleLabel.text = sectionType.title
//            return header
//        }
//        /**
//        /// Helper method để ánh xạ `CartSection` thành tiêu đề header
//        private func headerTitle(for section: CartSection) -> String {
//            switch section {
//            case .guaranteed:
//                return "You're protected at MY APP"
//            case .recommended:
//                return "Recommended for you"
//            default:
//                return ""
//            }
//        }
//         */
//    }
//}
