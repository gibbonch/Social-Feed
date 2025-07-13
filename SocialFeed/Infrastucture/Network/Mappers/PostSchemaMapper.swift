import Foundation

// MARK: - Protocol

/// Протокол для маппинга данных между сетевой схемой и доменной моделью.
protocol PostSchemaMapperProtocol {
    
    /// Преобразует сетевую схему поста в доменную модель.
    func mapToDomain(_ schema: PostSchema,
                     localRepository: PostsRepository,
                     completion: @escaping (Result<Post, any Error>) -> Void)
    
    /// Применяет отложенные действия пользователя к посту.
    func applyPendingActions(to post: Post,
                             likesManager: PendingLikeActionsManager) -> Post
}

// MARK: - Implementation

/// Реализация маппера для преобразования данных о постах между слоями приложения.
struct PostSchemaMapper {
    
    /// Преобразует сетевую схему поста в доменную модель.
    func mapToDomain(_ schema: PostSchema,
                     localRepository: PostsRepository,
                     completion: @escaping (Result<Post, Error>) -> Void) {
        
        localRepository.fetchPost(by: schema.id) { result in
            let isStored: Bool
            switch result {
            case .success:
                isStored = true
            case .failure:
                isStored = false
            }
            
            let post = Post(
                id: schema.id,
                username: schema.user.username,
                avatar: schema.user.avatar,
                title: schema.postTitle,
                text: schema.postText,
                image: schema.image,
                created: schema.created,
                totalLikes: schema.totalLikes,
                isLiked: schema.isLiked,
                isStored: isStored
            )
            
            completion(.success(post))
        }
    }
    
    /// Применяет отложенные действия пользователя к посту.
    func applyPendingActions(to post: Post,
                             likesManager: PendingLikeActionsManager) -> Post {
        let pendingActions = likesManager.pendingActions(for: post.id)
        
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
                pendingLike: latestAction.isLiked
            ),
            isLiked: latestAction.isLiked,
            isStored: post.isStored
        )
        
        return updatedPost
    }
    
    // MARK: - Private Methods
    
    private func calculateUpdatedLikes(currentLikes: Int,
                                       wasLiked: Bool,
                                       pendingLike: Bool) -> Int {
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
