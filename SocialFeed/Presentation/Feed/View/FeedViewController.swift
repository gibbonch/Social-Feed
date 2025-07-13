import UIKit
import Combine

final class FeedViewController: UIViewController {
    
    // MARK: - Section
    
    private enum Section {
        case main
    }
    
    // MARK: - Private Properties
    
    private let viewModel: FeedViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var feedView = FeedView()
    private var dataSource: UITableViewDiffableDataSource<Section, PostCellViewModel>!
    
    // MARK: - Lifecycle
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = feedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Social Feed"
        setupTableView()
        setupSegmentedControl()
        setupDataSource()
        setupBindings()
        viewModel.viewLoaded()
    }
    
    // MARK: - Private Methods
    
    private func setupTableView() {
        feedView.tableView.register(
            PostCell.self,
            forCellReuseIdentifier: PostCell.reuseIdentifier
        )
        feedView.tableView.delegate = self
        feedView.refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
    }
    
    private func setupDataSource() {
        dataSource = .init(tableView: feedView.tableView, cellProvider: { [weak self] tableView, indexPath, model in
            guard let postCell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier)
                    as? PostCell else {
                return UITableViewCell()
            }
            postCell.configure(viewModel: model)
            postCell.onTextExpansion = {
                self?.viewModel.postExpanded(at: indexPath)
            }
            postCell.onLikeTap = {
                self?.viewModel.likeTappedOnPost(with: model.id)
            }
            postCell.onStoreTap = {
                self?.viewModel.storeTappedOnPost(with: model.id)
            }
            return postCell
        })
    }
    
    private func setupBindings() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(with: state)
            }
            .store(in: &cancellables)
    }
    
    private func setupSegmentedControl() {
        feedView.segmentedControl.addTarget(
            self,
            action: #selector(segmentedControlValueChanged),
            for: .valueChanged
        )
    }
    
    private func updateUI(with state: FeedViewState) {
        if state.isLoading {
            feedView.activityIndicator.startAnimating()
            feedView.activityIndicator.isHidden = false
            feedView.tableView.isHidden = true
        } else {
            feedView.activityIndicator.stopAnimating()
            feedView.activityIndicator.isHidden = true
            feedView.tableView.isHidden = false
        }
        
        if !state.isRefreshing {
            feedView.refreshControl.endRefreshing()
        }
        
        applySnapshot(viewModels: state.posts)
    }
    
    private func applySnapshot(viewModels: [PostCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    @objc private func segmentedControlValueChanged() {
        let selectedIndex = feedView.segmentedControl.selectedSegmentIndex
        let segments = FeedSegment.allCases
        
        guard selectedIndex < segments.count else { return }
        
        let selectedSegment = segments[selectedIndex]
        viewModel.segmentChanged(to: selectedSegment)
    }
    
    @objc private func refreshFeed() {
        viewModel.refresh()
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        view.frame.width * 2 / 3 + 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Анимация segment control
        feedView.handleScrollViewDidScroll(scrollView)
        
        // Пагинация
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 1.2 {
            viewModel.loadNextPage()
        }
    }
}
