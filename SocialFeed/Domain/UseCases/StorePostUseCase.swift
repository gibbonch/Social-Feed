import Foundation

protocol StorePostUseCase {
    func execute(post: Post, onFailure: @escaping (any Error) -> Void)
}

final class StorePostUseCaseImpl: StorePostUseCase {
    private let localRepository: PostsRepository
    
    init(localRepository: PostsRepository) {
        self.localRepository = localRepository
    }
    
    func execute(post: Post, onFailure: @escaping (any Error) -> Void) {
        if post.isStored {
            localRepository.deletePost(by: post.id) { result in
                if case .failure(let error) = result {
                    onFailure(error)
                }
            }
        } else {
            localRepository.store(post: post) { result in
                if case .failure(let error) = result {
                    onFailure(error)
                }
            }
        }
    }
}
