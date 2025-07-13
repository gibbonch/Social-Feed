import UIKit

final class FeedView: UIView {
    
    // MARK: - Subviews
    
    private(set) lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Рекомендации", "Сохраненные"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Private Properties
    
    private var segmentedControlTopConstraint: NSLayoutConstraint!
    private var lastContentOffset: CGFloat = 0
    private let segmentedControlHeight: CGFloat = 28
    private let animationDuration: TimeInterval = 0.3
    private var isControlHidden = false
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubview(segmentedControl)
        addSubview(tableView)
        backgroundColor = .white
    }
    
    private func setupConstraints() {
        segmentedControlTopConstraint = segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8)
        
        NSLayoutConstraint.activate([
            segmentedControlTopConstraint,
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 44),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -44),
            segmentedControl.heightAnchor.constraint(equalToConstant: segmentedControlHeight),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func handleScrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentOffset: CGFloat = scrollView.contentOffset.y
        
        if currentOffset < 0 {
            currentOffset = 0
        }
        
        if currentOffset > scrollView.frame.height {
            currentOffset = scrollView.frame.height
        }
        
        let offsetDifference = currentOffset - lastContentOffset
        
        print(currentOffset, lastContentOffset)
        
        let threshold: CGFloat = 10
        
        if abs(offsetDifference) > threshold {
            lastContentOffset = currentOffset
            if offsetDifference > 0 {
                hideSegmentedControl()
            } else {
                showSegmentedControl()
            }
        }
    }
    
    private func hideSegmentedControl() {
        guard segmentedControlTopConstraint.constant >= 0 else { return }
        
        segmentedControlTopConstraint.constant = -(segmentedControlHeight + 16)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.layoutIfNeeded()
            }
        )
    }
    
    private func showSegmentedControl() {
        guard segmentedControlTopConstraint.constant < 0 else { return }
        
        segmentedControlTopConstraint.constant = 8
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.layoutIfNeeded()
            }
        )
    }
}
