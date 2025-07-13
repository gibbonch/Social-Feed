import Foundation

/// Представляет отложенное действие лайка для поста
struct PendingLikeAction {
    let postId: String
    let timestamp: Date
    let isLiked: Bool
}
