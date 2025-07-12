import Foundation

protocol FetchPostsUseCase {
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void)
}

final class FetchPostsUseCaseImpl: FetchPostsUseCase {
    
    private let postProvider: PostsProviding
    private let favoriteManager: FavoriteManaging
    
    init(postProvider: PostsProviding, favoriteManager: FavoriteManaging) {
        self.postProvider = postProvider
        self.favoriteManager = favoriteManager
    }
    
    func execute(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void) {
        postProvider.fetchPosts(page: page, perPage: perPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let schemas):
                let posts = self.mapSchemaToPosts(schemas)
                completion(.success(posts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func mapSchemaToPosts(_ schemas: [PostSchema]) -> [Post] {
        return schemas.map { schema in
            let mappedPost = mapSchemaToPost(schema)
            return applyPendingActions(to: mappedPost)
        }
    }
    
    private func mapSchemaToPost(_ schema: PostSchema) -> Post {
        return Post(
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
    
    private func applyPendingActions(to post: Post) -> Post {
        let pendingActions = favoriteManager.pendingActions(for: post.id)
        
        guard let latestAction = pendingActions.sorted(by: { $0.timestamp > $1.timestamp }).first else {
            return post
        }
        
        let updatedPost = Post(
            id: post.id,
            username: post.username,
            avatar: post.avatar,
            title: post.title,
            text: post.text,
            image: post.image,
            created: post.created,
            totalLikes: calculateUpdatedLikes(
                currentLikes: post.totalLikes,
                wasLiked: post.isLiked,
                pendingLike: latestAction.liked
            ),
            isLiked: latestAction.liked,
            isStored: post.isStored
        )
        
        return updatedPost
    }
    
    private func calculateUpdatedLikes(currentLikes: Int, wasLiked: Bool, pendingLike: Bool) -> Int {
        switch (wasLiked, pendingLike) {
        case (false, true):
            return currentLikes + 1
        case (true, false):
            return max(0, currentLikes - 1)
        case (false, false), (true, true):
            return currentLikes
        }
    }
}
