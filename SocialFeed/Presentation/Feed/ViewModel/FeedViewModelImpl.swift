import Combine
import Foundation

final class FeedViewModelImpl {
    
    // MARK: - Private Properties
    
    private var localState = FeedViewState()
    private var remoteState = FeedViewState()
    private var selectedSegment: FeedSegment = .remote
    
    private let stateSubject = CurrentValueSubject<FeedViewState, Never>(FeedViewState())
    
    private let fetchPostsFromServerUseCase: FetchPostsUseCase
    private let fetchPostsFromCoreDataUseCase: FetchPostsUseCase
    private let likePostUseCase: LikePostUseCase
    private let storePostUseCase: StorePostUseCase
    
    // MARK: - Lifecycle
    
    init(fetchPostsFromServerUseCase: FetchPostsUseCase,
         fetchPostsFromCoreDataUseCase: FetchPostsUseCase,
         likePostUseCase: LikePostUseCase,
         storePostUseCase: StorePostUseCase) {
        
        self.fetchPostsFromServerUseCase = fetchPostsFromServerUseCase
        self.fetchPostsFromCoreDataUseCase = fetchPostsFromCoreDataUseCase
        self.likePostUseCase = likePostUseCase
        self.storePostUseCase = storePostUseCase
    }
    
    // MARK: - Private Methods
    
    private func loadRemotePosts() {
        guard remoteState.needsLoad else { return }
        remoteState.needsLoad = false
        
        fetchPostsFromServerUseCase.execute(page: remoteState.page, perPage: remoteState.perPage) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let posts):
                    let viewModels = posts.map {
                        let builder = PostCellViewModelBuilder(post: $0)
                        return builder.build()
                    }
                    
                    remoteState.needsLoad = posts.count == remoteState.perPage
                    remoteState.posts.append(contentsOf: viewModels)
                    remoteState.isLoading = false
                    remoteState.isRefreshing = false
                    remoteState.page += 1
                    
                case .failure:
                    break
                }
                
                if selectedSegment == .remote {
                    stateSubject.send(remoteState)
                }
            }
        }
    }
    
    private func loadLocalPosts() {
        guard localState.needsLoad else { return }
        localState.needsLoad = false
        
        fetchPostsFromCoreDataUseCase.execute(page: localState.page, perPage: localState.perPage) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let posts):
                    let viewModels = posts.map {
                        let builder = PostCellViewModelBuilder(post: $0)
                        return builder.build()
                    }
                    
                    localState.needsLoad = posts.count == localState.perPage
                    localState.posts.append(contentsOf: viewModels)
                    localState.isLoading = false
                    localState.isRefreshing = false
                    localState.page += 1
                    
                case .failure:
                    break
                }
                
                if selectedSegment == .local {
                    stateSubject.send(localState)
                }
            }
        }
    }
    
    private var currentState: FeedViewState {
        get {
            switch selectedSegment {
            case .remote:
                return remoteState
            case .local:
                return localState
            }
        }
        set {
            switch selectedSegment {
            case .remote:
                remoteState = newValue
            case .local:
                localState = newValue
            }
        }
    }
}

// MARK: - FeedViewModel

extension FeedViewModelImpl: FeedViewModel {
    
    var state: AnyPublisher<FeedViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    func viewLoaded() {
        loadRemotePosts()
        loadLocalPosts()
    }
    
    func loadNextPage() {
        switch selectedSegment {
        case .remote:
            if AppConfiguration.environment != .mock {
                loadRemotePosts()
            }
        case .local:
            loadLocalPosts()
        }
    }
    
    func segmentChanged(to segment: FeedSegment) {
        selectedSegment = segment
        stateSubject.send(currentState)
    }
    
    func likeTappedOnPost(with id: String) {
        guard let currentIndex = currentState.posts.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let post = currentState.posts[currentIndex]
        let newLikedState = !post.isLiked
        
        var builder = PostCellViewModelBuilder(postCellViewModel: post)
        builder.isLiked = newLikedState
        builder.totalLikes = newLikedState ? post.totalLikes + 1 : max(0, post.totalLikes - 1)
        let updatedCellModel = builder.build()
        
        currentState.posts[currentIndex] = updatedCellModel
        
        switch selectedSegment {
        case .remote:
            if let localIndex = localState.posts.firstIndex(where: { $0.id == id }) {
                var localBuilder = PostCellViewModelBuilder(postCellViewModel: localState.posts[localIndex])
                localBuilder.isLiked = newLikedState
                localBuilder.totalLikes = newLikedState ? localState.posts[localIndex].totalLikes + 1 : max(0, localState.posts[localIndex].totalLikes - 1)
                localState.posts[localIndex] = localBuilder.build()
            }
        case .local:
            if let remoteIndex = remoteState.posts.firstIndex(where: { $0.id == id }) {
                var remoteBuilder = PostCellViewModelBuilder(postCellViewModel: remoteState.posts[remoteIndex])
                remoteBuilder.isLiked = newLikedState
                remoteBuilder.totalLikes = newLikedState ? remoteState.posts[remoteIndex].totalLikes + 1 : max(0, remoteState.posts[remoteIndex].totalLikes - 1)
                remoteState.posts[remoteIndex] = remoteBuilder.build()
            }
        }
        
        likePostUseCase.execute(postId: post.id, isLiked: newLikedState)
        
        if updatedCellModel.isStored {
            let targetPost = Post(
                id: updatedCellModel.id,
                username: updatedCellModel.username,
                avatar: updatedCellModel.avatarURL?.absoluteString ?? "",
                title: updatedCellModel.title,
                text: updatedCellModel.text,
                image: updatedCellModel.postImageURL?.absoluteString ?? "",
                created: updatedCellModel.created,
                totalLikes: updatedCellModel.totalLikes,
                isLiked: updatedCellModel.isLiked,
                isStored: updatedCellModel.isStored
            )
            
            storePostUseCase.execute(post: targetPost) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        print("Failed to update stored post with id: \(id)")
                        var revertBuilder = PostCellViewModelBuilder(postCellViewModel: updatedCellModel)
                        revertBuilder.isLiked = post.isLiked
                        revertBuilder.totalLikes = post.totalLikes
                        let revertedCellModel = revertBuilder.build()
                        
                        self.currentState.posts[currentIndex] = revertedCellModel
                        
                        switch self.selectedSegment {
                        case .remote:
                            if let localIndex = self.localState.posts.firstIndex(where: { $0.id == id }) {
                                self.localState.posts[localIndex] = revertedCellModel
                            }
                        case .local:
                            if let remoteIndex = self.remoteState.posts.firstIndex(where: { $0.id == id }) {
                                self.remoteState.posts[remoteIndex] = revertedCellModel
                            }
                        }
                        
                        self.stateSubject.send(self.currentState)
                    }
                }
            }
        }
        
        stateSubject.send(currentState)
    }
    
    func storeTappedOnPost(with id: String) {
        guard let index = currentState.posts.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        let cellModel = currentState.posts[index]
        
        let targetPost = Post(
            id: cellModel.id,
            username: cellModel.username,
            avatar: cellModel.avatarURL?.absoluteString ?? "",
            title: cellModel.title,
            text: cellModel.text,
            image: cellModel.postImageURL?.absoluteString ?? "",
            created: cellModel.created,
            totalLikes: cellModel.totalLikes,
            isLiked: cellModel.isLiked,
            isStored: cellModel.isStored
        )
        
        var builder = PostCellViewModelBuilder(postCellViewModel: cellModel)
        builder.isStored.toggle()
        let updatedCellModel = builder.build()
        currentState.posts[index] = updatedCellModel
        
        storePostUseCase.execute(post: targetPost) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(_):
                    if self.selectedSegment == .remote {
                        self.localState.posts.removeAll()
                        self.localState.needsLoad = true
                        self.localState.page = 0
                        self.loadLocalPosts()
                    } else {
                        self.localState.posts = self.localState.posts.filter { $0.id != updatedCellModel.id }
                        
                        if let index = self.remoteState.posts.firstIndex(where: { $0.id == updatedCellModel.id }) {
                            self.remoteState.posts[index] = updatedCellModel
                        }
                        self.stateSubject.send(self.currentState)
                    }
                case .failure(_):
                    print("failed to store post with id: \(id)")
                    var builder = PostCellViewModelBuilder(postCellViewModel: updatedCellModel)
                    builder.isStored.toggle()
                    self.currentState.posts[index] = builder.build()
                    self.stateSubject.send(self.currentState)
                }
            }
        }
        
        stateSubject.send(currentState)
    }
    
    func postExpanded(at indexPath: IndexPath) {
        let targetPost = currentState.posts[indexPath.row]
        if let index = currentState.posts.firstIndex(where: { $0.id == targetPost.id }) {
            var builder = PostCellViewModelBuilder(postCellViewModel: currentState.posts[index])
            builder.isExpanded.toggle()
            currentState.posts[index] = builder.build()
            stateSubject.send(currentState)
        }
    }
    
    func refresh() {
        currentState.isRefreshing = true
        currentState.posts.removeAll()
        currentState.page = 0
        currentState.needsLoad = true
        
        if selectedSegment == .local {
            loadLocalPosts()
        } else {
            loadRemotePosts()
        }
    }
}
