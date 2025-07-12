import Foundation

protocol LikePostUseCase {
    func execute(postId: String, isLiked: Bool)
}

final class LikePostUseCaseImpl: LikePostUseCase {
    private let client: NetworkClient
    private let favoritesManager: FavoriteManaging
    
    init(client: NetworkClient, favoritesManager: FavoriteManaging) {
        self.client = client
        self.favoritesManager = favoritesManager
    }
    
    func execute(postId: String, isLiked: Bool) {
        // сделать запрос и при ошибке сохранить на устройстве
        if isLiked {
            favoritesManager.addPendingLike(postId)
        } else {
            favoritesManager.addPendingUnlike(postId)
        }
    }
}
