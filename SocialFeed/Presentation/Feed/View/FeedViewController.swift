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
                self?.viewModel.likeTappedOnPost(at: indexPath)
            }
            postCell.onStoreTap = {
                self?.viewModel.storeTappedOnPost(at: indexPath)
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
    
    private func updateUI(with state: FeedViewState) {
        applySnapshot(viewModels: state.posts)
    }
    
    private func applySnapshot(viewModels: [PostCellViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels)
        dataSource?.apply(snapshot, animatingDifferences: false)
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
            viewModel.loadNextPageIfNeeded()
        }
    }
}
