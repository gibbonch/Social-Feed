import Foundation

/// Модель, описывающая опубликованный пост.
struct Post {
    
    /// Уникальный идентификатор поста.
    let id: String
    
    /// Никнейм пользователя.
    let username: String
    
    /// Аватар пользователя.
    let avatar: String?
    
    /// Заголовок поста.
    let title: String
    
    /// Текст поста.
    let text: String
    
    /// Изображение поста.
    let image: String
    
    /// Дата создания.
    let created: Date
    
    /// Общее количество лайков.
    let totalLikes: Int
    
    /// True, если текущий пользователь поставил лайк.
    let isLiked: Bool
    
    /// True, если пост сохранен на устройстве.
    let isStored: Bool
}
