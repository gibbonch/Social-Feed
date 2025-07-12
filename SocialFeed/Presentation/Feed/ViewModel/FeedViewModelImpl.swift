import Combine
import Foundation

final class FeedViewModelImpl {
    
    // MARK: - Private Properties
    
    private let stateSubject = CurrentValueSubject<FeedViewState, Never>(FeedViewState())
    private let fetchPostsUseCase: FetchPostsUseCase
    
    private var currentState: FeedViewState {
        stateSubject.value
    }
    
    // MARK: - Lifecycle
    
    init(fetchPostsUseCase: FetchPostsUseCase) {
        self.fetchPostsUseCase = fetchPostsUseCase
    }
    
    // MARK: - Private Methods
    
    private func loadPosts() {
        guard !currentState.isLoading && currentState.hasMoreData else {
            return
        }
        
        updateState { $0.isLoading = true }
        
        fetchPostsUseCase.execute(page: currentState.page,
                                  perPage: currentState.perPage) { [weak self] result in
            switch result {
            case .success(let posts):
                let viewModels = posts.map { post in
                    let builder = PostCellViewModelBuilder(post: post)
                    return builder.build()
                }
                
                self?.updateState {
                    $0.page += 1
                    $0.isLoading = false
                    $0.posts.append(contentsOf: viewModels)
                    
                    if posts.count < $0.perPage {
                        $0.hasMoreData = false
                    }
                }
                
            case .failure(let error):
                self?.updateState { $0.isLoading = false }
                print(error)
            }
        }
    }
    
    private func updateState(_ mutation: (inout FeedViewState) -> Void) {
        var newState = stateSubject.value
        mutation(&newState)
        stateSubject.send(newState)
    }
}

// MARK: - FeedViewModel (обновленный протокол)
extension FeedViewModelImpl: FeedViewModel {
    var state: AnyPublisher<FeedViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func viewLoaded() {
        loadPosts()
    }
    
    func loadNextPageIfNeeded() {
        loadPosts()
    }
    
    func likeTappedOnPost(at indexPath: IndexPath) { }
    
    func storeTappedOnPost(at indexPath: IndexPath) { }
    
    func postExpanded(at indexPath: IndexPath) {
        guard indexPath.row < currentState.posts.count else { return }
        
        let targetPost = currentState.posts[indexPath.row]
        
        updateState { state in
            if let index = state.posts.firstIndex(where: { $0.id == targetPost.id }) {
                var builder = PostCellViewModelBuilder(postCellViewModel: state.posts[index])
                builder.isExpanded.toggle()
                state.posts[index] = builder.build()
            }
        }
    }
}
