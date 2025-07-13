import Foundation

/// Запрашивает данные о постах с сервера и производит синхранизацию с локальными данными.
final class RemotePostsProvider: PostsProviding {
    
    // MARK: - Private Properties
    
    private let client: NetworkClient
    private let likesManager: PendingLikeActionsManager
    private let localRepository: PostsRepository
    private let mapper = PostSchemaMapper()
    
    // MARK: - Lifecycle
    
    init(client: NetworkClient,
         likesManager: PendingLikeActionsManager,
         localReportRepository: PostsRepository) {
        self.client = client
        self.likesManager = likesManager
        self.localRepository = localReportRepository
    }
    
    // MARK: - Internal Methods
    
    /// Запрашивает список постов с сервера с пагинацией.
    /// Применяет отложенные действия пользователя к полученным постам
    /// и наличие постов в локальном хранилище.
    func fetchPosts(page: Int,
                    perPage: Int,
                    completion: @escaping (Result<[Post], any Error>) -> Void) {
        let endpoint = PostsEndpoint.getPosts(page: page, perPage: perPage)
        
        client.request(endpoint, responseType: [PostSchema].self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let schemas):
                processSchemas(schemas, completion: completion)
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Запрашивает конкретный пост по его идентификатору.
    func fetchPost(by id: String, completion: (Result<Post, any Error>) -> Void) {
        // TODO: Реализовать запрос постов по идентификатор.
        assertionFailure("Not Implemented")
    }
    
    // MARK: - Private Methods
    
    private func processSchemas(_ schemas: [PostSchema],
                                completion: @escaping (Result<[Post], any Error>) -> Void) {
        var posts: [Post?] = Array(repeating: nil, count: schemas.count)
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        
        for (index, schema) in schemas.enumerated() {
            group.enter()
            mapper.mapToDomain(schema, localRepository: localRepository) { [weak self] result in
                guard let self else { return }
                if case let .success(post) = result {
                    let finalPost = mapper.applyPendingActions(to: post, likesManager: likesManager)
                    semaphore.wait()
                    posts[index] = finalPost
                    semaphore.signal()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            let orderedPosts = posts.compactMap { $0 }
            completion(.success(orderedPosts))
        }
    }
}
