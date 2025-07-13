import Foundation

protocol StorePostUseCase {
    func execute(post: Post, completion: @escaping (Result<Void, any Error>) -> Void)
}

final class StorePostUseCaseImpl: StorePostUseCase {
    private let localRepository: PostsRepository
    
    init(localRepository: PostsRepository) {
        self.localRepository = localRepository
    }
    
    func execute(post: Post, completion: @escaping (Result<Void, any Error>) -> Void) {
        if post.isStored {
            localRepository.deletePost(by: post.id) { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            localRepository.store(post: post) { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
