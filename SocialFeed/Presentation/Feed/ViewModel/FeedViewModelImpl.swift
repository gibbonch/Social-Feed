import Combine
import Foundation

final class FeedViewModelImpl {
    
    // MARK: - Private Properties
    
    private let stateSubject = CurrentValueSubject<FeedViewState, Never>(FeedViewState())
    private let fetchPostsUseCase: FetchPostsUseCase
    private let likePostUseCase: LikePostUseCase
    private let storePostUseCase: StorePostUseCase
    
    private var currentState: FeedViewState {
        stateSubject.value
    }
    
    // MARK: - Lifecycle
    
    init(fetchPostsUseCase: FetchPostsUseCase,
         likePostUseCase: LikePostUseCase,
         storePostUseCase: StorePostUseCase
    ) {
        self.fetchPostsUseCase = fetchPostsUseCase
        self.likePostUseCase = likePostUseCase
        self.storePostUseCase = storePostUseCase
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
                
            case .failure(_):
                self?.updateState { $0.isLoading = false }
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
        if AppConfiguration.environment != .mock {
            loadPosts()
        }
    }
    
    func likeTappedOnPost(at indexPath: IndexPath) {
        let post = currentState.posts[indexPath.row]
        likePostUseCase.execute(postId: post.id, isLiked: !post.isLiked)
        
        updateState { state in
            if let index = state.posts.firstIndex(where: { $0.id == post.id }) {
                var builder = PostCellViewModelBuilder(postCellViewModel: state.posts[index])
                builder.isLiked = !post.isLiked
                let currentLikes = state.posts[index].totalLikes
                if !post.isLiked {
                    builder.totalLikes = currentLikes + 1
                } else {
                    builder.totalLikes = max(0, currentLikes - 1)
                }
                
                state.posts[index] = builder.build()
            }
        }
    }
    
    func storeTappedOnPost(at indexPath: IndexPath) {
        let postViewModel = currentState.posts[indexPath.row]
        let post = Post(
            id: postViewModel.id,
            username: postViewModel.username,
            avatar: postViewModel.avatarURL?.absoluteString ?? "",
            title: postViewModel.title,
            text: postViewModel.text,
            image: postViewModel.postImageURL?.absoluteString ?? "",
            created: postViewModel.created,
            totalLikes: postViewModel.totalLikes,
            isLiked: postViewModel.isLiked,
            isStored: postViewModel.isStored
        )
        
        storePostUseCase.execute(post: post) { error in
            DispatchQueue.main.async {
                print("Error storing: \(error)")
            }
        }
        
        updateState { state in
            if let index = state.posts.firstIndex(where: { $0.id == post.id }) {
                var builder = PostCellViewModelBuilder(postCellViewModel: state.posts[index])
                builder.isStored = !post.isStored
                state.posts[index] = builder.build()
            }
        }
    }
    
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
