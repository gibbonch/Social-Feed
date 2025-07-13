import Foundation

// MARK: - Protocol

protocol LikePostUseCase {
    func execute(postId: String, isLiked: Bool)
}

// MARK: - Implementation

final class LikePostUseCaseImpl: LikePostUseCase {
    
    private let client: NetworkClient
    private let likesManager: PendingLikeActionsManager
    
    init(client: NetworkClient, likesManager: PendingLikeActionsManager) {
        self.client = client
        self.likesManager = likesManager
    }
    
    func execute(postId: String, isLiked: Bool) {
        
        // сделать запрос и при ошибке сохранить на устройстве
        
        if isLiked {
            likesManager.queueLikeAction(for: postId)
        } else {
            likesManager.queueUnlikeAction(for: postId)
        }
    }
}
