import Foundation

/// Содержит зависимости необходимые для построения сцен.
final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private init() { }
    
    // MARK: - Base
    
    private lazy var networkClient: NetworkClient = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 60
        config.urlCache = URLCache(
            memoryCapacity: Storage.inMemory.capacity,
            diskCapacity: 100 * 1024 * 1024
        )
        config.requestCachePolicy = .useProtocolCachePolicy
        return NetworkClient(configuration: config)
    }()
    
    private lazy var contextProvider = CoreDataStack()
    
    // MARK: - Services
    
    lazy var likesManager: PendingLikeActionsManager = {
        PendingLikeActionsManager(contextProvider: contextProvider)
    }()
    
    lazy var localPostsRepository: PostsRepository = {
        LocalPostsRepository(contextProvider: contextProvider)
    }()
    
    lazy var remotePostsProvider: PostsProviding = {
        RemotePostsProvider(
            client: networkClient,
            likesManager: likesManager,
            localReportRepository: localPostsRepository
        )
    }()
    
    // MARK: - Use Cases
    
    var fetchPostsFromServerUseCase: FetchPostsUseCase {
        FetchPostsUseCaseImpl(
            postProvider: remotePostsProvider,
        )
    }
    
    var fetchPostsFromCoreDataUseCase: FetchPostsUseCase {
        FetchPostsUseCaseImpl(
            postProvider: localPostsRepository,
        )
    }
    
    var likePostUseCase: LikePostUseCase {
        LikePostUseCaseImpl(
            client: networkClient,
            likesManager: likesManager
        )
    }
    
    var storePostUseCase: StorePostUseCase {
        StorePostUseCaseImpl(localRepository: localPostsRepository)
    }
}
