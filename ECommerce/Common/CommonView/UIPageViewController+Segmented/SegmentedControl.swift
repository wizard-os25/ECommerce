//
//  SegmentedControl 2.swift
//  MyKiot
//
//  Created by Nguyen Duc Hung on 13/6/25.
//


import UIKit

@IBDesignable class SegmentedControl: UIControl {
    var labels = [UILabel]()
    var thumbView = UIView()
    private var tabWidths: [CGFloat] = []
    
    var didSelectIndex: ((Int) -> Void)?
    
    // Callback when MainVC has ChildVC
    var items: [String] = [""] {
        didSet {
            self.setupLabels()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            self.displayNewSelectedIndex()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func totalTabWidth() -> CGFloat {
        return self.tabWidths.reduce(0, +)
    }
    
    func setupView() {
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = UIColor.clear
        
        self.setupLabels()
        insertSubview(self.thumbView, at: 0)
    }
    

    func setupLabels() {
        // Xóa label cũ
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll(keepingCapacity: true)
        tabWidths.removeAll()

        // ThumbView thêm lại ở dưới (nếu chưa có trong view)
        if thumbView.superview == nil {
            thumbView.isUserInteractionEnabled = false
            insertSubview(thumbView, at: 0)
        }

        // Thêm label
        for (index, item) in items.enumerated() {
            let label = UILabel()
            label.text = item
            label.textAlignment = .center
            label.textColor = #colorLiteral(red: 0.6784313725, green: 0.6862745098, blue: 0.6980392157, alpha: 1)
            label.font = .systemFont(ofSize: 14)
            label.isUserInteractionEnabled = true
            label.tag = index

            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
            label.addGestureRecognizer(tap)

            addSubview(label)
            labels.append(label)

            label.sizeToFit()
            let width = label.intrinsicContentSize.width + 16
            print("---> width: \(width)")
            
            tabWidths.append(width)
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
//
//    func setupLabels() {
//        for label in labels {
//            label.removeFromSuperview()
//        }
//        self.labels.removeAll(keepingCapacity: true)
//        
//        self.tabWidths.removeAll()
//        
//        for (index, item) in items.enumerated() {
//            let label = UILabel()
//            label.text = item
//            label.textAlignment = .center
//            label.textColor = #colorLiteral(red: 0.6784313725, green: 0.6862745098, blue: 0.6980392157, alpha: 1)
//            label.font = .systemFont(ofSize: 14)
//            label.sizeToFit()
//            /// Enable User touch
//            label.isUserInteractionEnabled = true
//            label.backgroundColor = .yellow.withAlphaComponent(0.3)
//            
//            label.tag = index
//            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
//            label.addGestureRecognizer(tap)
//
//            self.addSubview(label)
//            
//            self.labels.append(label)
//            
//            // Lấy width intrinsic của label + padding 12pt (6pt mỗi bên)
//            let width = label.intrinsicContentSize.width + 16
//            self.tabWidths.append(width)
//        }
//        
//        self.setNeedsLayout()
//    }
    
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        let index = tappedLabel.tag
        self.selectedIndex = index
        sendActions(for: .valueChanged)
        self.didSelectIndex?(index)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("SegmentedControl frame: \(self.frame)")
        print("Labels frames: \(labels.map { $0.frame })")
        
        let spacingBetweenLabels: CGFloat = 12
        //let totalLabelWidth = tabWidths.reduce(0, +)
        //let totalSpacing = spacingBetweenLabels * CGFloat(tabWidths.count - 1)
        
        var xOffset: CGFloat = 0
        
        for (index, label) in labels.enumerated() {
            let labelWidth = tabWidths[index] //* scaleFactor
            label.frame = CGRect(x: xOffset, y: 0, width: labelWidth, height: bounds.height)
            xOffset += labelWidth + spacingBetweenLabels
        }
        
        // Cập nhật thumbView frame
        if selectedIndex < labels.count {
            let selectedLabel = labels[selectedIndex]
            // Thumb nhỏ hơn label 8pt (4pt padding mỗi bên)
            let padding: CGFloat = 0
            let thumbX = selectedLabel.frame.origin.x + padding
            let thumbWidth = selectedLabel.frame.width - 2 * padding
            
            thumbView.frame = CGRect(x: thumbX, y: 0, width: thumbWidth, height: bounds.height)
            thumbView.backgroundColor = UIColor.white
            thumbView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            thumbView.layer.borderWidth = 1
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
            thumbView.isUserInteractionEnabled = false
        }
        
        // Quan trọng: cập nhật contentSize của UIScrollView (nếu có superview là scrollView)
        if let scrollView = self.superview as? UIScrollView {
            scrollView.contentSize = CGSize(width: xOffset, height: bounds.height)
        }
    }
    
    func displayNewSelectedIndex() {
        for (index, label) in labels.enumerated() {
            label.textColor = index == selectedIndex ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.6784313725, green: 0.6862745098, blue: 0.6980392157, alpha: 1)
        }
        
        UIView.animate(withDuration: 0.25) {
            let label = self.labels[self.selectedIndex]
            let padding: CGFloat = 4
            let thumbX = label.frame.origin.x + padding
            let thumbWidth = label.frame.width - 2 * padding
            self.thumbView.frame = CGRect(x: thumbX, y: 0, width: thumbWidth, height: self.bounds.height)
        }
        
        // 👇 Tự động scroll sao cho label hiện tại nằm ở giữa hoặc gần giữa
        if let scrollView = self.superview as? UIScrollView {
            let selectedLabel = labels[selectedIndex]
            let labelMidX = selectedLabel.frame.midX
            let scrollViewWidth = scrollView.bounds.width
            
            // Tính offset sao cho label được chọn nằm gần giữa
            var targetOffsetX = labelMidX - scrollViewWidth / 2
            
            // Clamp để không scroll quá giới hạn
            targetOffsetX = max(0, min(targetOffsetX, scrollView.contentSize.width - scrollViewWidth))
            
            scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        }
        
    }
    
    /// UIControl own this method
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        let location = touch.location(in: self)
//        
//        var calculatedIndex: Int?
//        
//        for (index, item) in labels.enumerated() {
//            if item.frame.contains(location) {
//                calculatedIndex = index
//            }
//        }
//        
//        if calculatedIndex != nil {
//            selectedIndex = calculatedIndex!
//            sendActions(for: .valueChanged)
//            
//            self.didSelectIndex?(self.selectedIndex)
//        }
//        
//        /// Enable touch to swift the tap
//        return true
//    }
    
    // MARK: - Update thumb on scroll
    func updateThumbPosition(progress: CGFloat) {
        guard items.count > 1 else { return }
        
        let clamped = min(CGFloat(items.count - 1), max(0, progress))
        
        let segmentWidth = bounds.width / CGFloat(items.count)
        let newX = clamped * segmentWidth
        
        UIView.performWithoutAnimation {
            self.thumbView.frame = CGRect(x: newX, y: 0, width: segmentWidth, height: bounds.height)
            
        }
    }
}
