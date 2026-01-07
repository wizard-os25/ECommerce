// SegmentedPageContainer.swift (fixed)
import UIKit

class SegmentedPageContainer: UIView {

    var onTabChanged: ((Int) -> Void)?

    private var isSetupDone: Bool = false

    // Make currentIndex readable outside but writable only inside
    private(set) var currentIndex: Int = 0

    private let tabScrollView = UIScrollView()
    private let segmentedControl = SegmentedControl()
    private var pageViewController: UIPageViewController!

    // Keep strong refs to view controllers
    var viewControllers: [UIViewController] = []

    private weak var parentVC: UIViewController?

    // keep width constraint to update later
    private var segmentedControlWidthConstraint: NSLayoutConstraint?

    deinit {
        print("SegmentedPageContainer deinitialized")
    }

    // MARK: - Public API

    func configUI(titles: [String],
                   viewControllers: [UIViewController],
                   parent: UIViewController,
                   defaultIndex: Int = 0) {

        // set items before layout
        self.segmentedControl.items = titles
        self.viewControllers = viewControllers
        self.parentVC = parent

        // use closure (single source of truth) when user taps segmentedControl
        self.segmentedControl.didSelectIndex = { [weak self] index in
            guard let self = self else { return }
            self.setPage(index: index, animated: true)
            self.onTabChanged?(index)
        }

        // select default
        self.segmentedControl.selectedIndex = defaultIndex

        self.setupView()
        self.setupPageViewController()
        // set initial page (no animation)
        self.setPage(index: defaultIndex, animated: false)
    }

    // MARK: - Setup Views
    private func setupView() {
        guard !self.isSetupDone else { return }
        self.isSetupDone = true

        self.tabScrollView.showsHorizontalScrollIndicator = false
        self.tabScrollView.bounces = true
        self.tabScrollView.alwaysBounceHorizontal = true
        self.tabScrollView.delaysContentTouches = false
        self.tabScrollView.canCancelContentTouches = true
        self.tabScrollView.translatesAutoresizingMaskIntoConstraints = false

        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.tabScrollView)
        self.tabScrollView.addSubview(self.segmentedControl)

        NSLayoutConstraint.activate([
            self.tabScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            self.tabScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.tabScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.tabScrollView.heightAnchor.constraint(equalToConstant: 32),

            self.segmentedControl.leadingAnchor.constraint(equalTo: self.tabScrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            // trailing anchor to scrollView's contentLayoutGuide will be updated by width constraint
            self.segmentedControl.topAnchor.constraint(equalTo: self.tabScrollView.contentLayoutGuide.topAnchor),
            self.segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Create width constraint but don't set constant yet (will set in layoutSubviews)
        let widthConstraint = self.segmentedControl.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true
        self.segmentedControlWidthConstraint = widthConstraint

        // Only use closure handler above; do NOT addTarget here to avoid double-calls
        // self.segmentedControl.addTarget(self, action: #selector(self.tabChanged(_:)), for: .valueChanged)
    }

    private func setupPageViewController() {
        guard let parent = parentVC else { return }

        self.pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self

        parent.addChild(self.pageViewController)
        addSubview(self.pageViewController.view)

        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pageViewController.view.topAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor, constant: 4),
            self.pageViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.pageViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.pageViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.pageViewController.didMove(toParent: parent)

        // Important: find UIPageViewController's UIScrollView and set delegate
        // Do it async to ensure subviews are laid out
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for subview in self.pageViewController.view.subviews {
                if let scrollView = subview as? UIScrollView {
                    scrollView.delegate = self
                    // do not alter other properties unless needed
                    break
                }
            }
        }
    }

    @objc private func tabChanged(_ sender: SegmentedControl) {
        let index = sender.selectedIndex
        self.setPage(index: index, animated: true)
        self.onTabChanged?(index)
    }

    private func setPage(index: Int, animated: Bool) {
        guard index < viewControllers.count, index >= 0 else { return }

        let direction: UIPageViewController.NavigationDirection = (index >= self.currentIndex) ? .forward : .reverse

        // use completion to sync currentIndex after transition finishes
        self.pageViewController.setViewControllers(
            [self.viewControllers[index]],
            direction: direction,
            animated: animated,
            completion: { [weak self] finished in
                guard let self = self else { return }
                // If animation completed or we set without animation, update currentIndex immediately
                self.currentIndex = index
                self.segmentedControl.selectedIndex = index
            }
        )
    }

    // MARK: Layout - compute segmentedControl width after AutoLayout
    override func layoutSubviews() {
        super.layoutSubviews()

        // Calculate segmented control total width after its layout is known.
        // Run once or when items change.
        guard let widthConstraint = segmentedControlWidthConstraint else { return }

        // Measure total tab width from segmentedControl's own method (assume it uses items)
        let measuredTotal = self.segmentedControl.totalTabWidth() + 32 // padding
        if measuredTotal > 0 && widthConstraint.constant != measuredTotal {
            widthConstraint.constant = measuredTotal
            // update layout immediately
            self.segmentedControl.layoutIfNeeded()
            self.tabScrollView.layoutIfNeeded()
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension SegmentedPageContainer: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController),
              index > 0 else {
            return nil
        }
        return self.viewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.viewControllers.firstIndex(of: viewController),
              index < self.viewControllers.count - 1 else {
            return nil
        }

        return self.viewControllers[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension SegmentedPageContainer: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let visibleVC = pageViewController.viewControllers?.first,
           let index = self.viewControllers.firstIndex(of: visibleVC) {
            self.segmentedControl.selectedIndex = index
            self.currentIndex = index
            self.onTabChanged?(index)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SegmentedPageContainer: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // page view width
        guard let viewWidth = scrollView.superview?.frame.width, viewWidth > 0 else { return }

        let offsetX = scrollView.contentOffset.x
        // default contentOffset for UIPageViewController's scroll view is pageWidth
        // progress: -1..0..1  we normalize to 0..1 forward
        let progress = (offsetX - viewWidth) / viewWidth

        let index = CGFloat(currentIndex)
        let newIndexFloat = index + progress

        // update segmented control thumb position using float-based progress
        self.segmentedControl.updateThumbPosition(progress: newIndexFloat)
    }
}
