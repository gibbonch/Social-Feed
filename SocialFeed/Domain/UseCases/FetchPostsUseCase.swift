import Foundation

// MARK: - Protocol

protocol FetchPostsUseCase {
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void)
}

// MARK: - Implementation

final class FetchPostsUseCaseImpl: FetchPostsUseCase {
    
    private let postProvider: PostsProviding
    
    init(postProvider: PostsProviding) {
        self.postProvider = postProvider
    }
    
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void) {
        postProvider.fetchPosts(page: page, perPage: perPage) { result in
            switch result {
            case .success(let posts):
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
