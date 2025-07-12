import Foundation

/// Ответ сервера на запрос поста.
struct PostSchema: Codable {
    
    let id: String
    let user: UserSchema
    let postTitle: String
    let postText: String
    let image: String
    let created: Date
    let totalLikes: Int
    let isLiked: Bool
    let lastLikeUpdate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case postTitle = "post_title"
        case postText = "post_text"
        case image
        case created = "created_at"
        case totalLikes = "total_likes"
        case isLiked = "liked"
        case lastLikeUpdate = "like_timestamp"
    }
}
