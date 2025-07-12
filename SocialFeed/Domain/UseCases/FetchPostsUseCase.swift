import Foundation

protocol FetchPostsUseCase {
    
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void)
}

final class FetchPostsUseCaseImpl: FetchPostsUseCase {
    private let postProvider: PostsProviding
    
    init(postProvider: PostsProviding) {
        self.postProvider = postProvider
    }
    
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void) {
        postProvider.fetchPosts(page: page, perPage: perPage) { result in
            
            switch result {
            case .success(let schemas):
                let posts = schemas.map { schema in
                    Post(
                        id: schema.id,
                         username: schema.user.username,
                        avatar: schema.user.avatar,
                        title: schema.postTitle,
                        text: schema.postText,
                        image: schema.image,
                        created: schema.created.description,
                        totalLikes: schema.totalLikes,
                        isLiked: schema.isLiked,
                        isStored: false
                    )
                }
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
