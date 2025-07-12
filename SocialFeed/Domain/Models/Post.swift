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
    /// Текст, описывающий когда был создан пост (пример: `"1 дн. назад"`)
    let created: String
    /// Общее количество лайков.
    let totalLikes: Int
    /// True, если текущий пользователь поставил лайк.
    let isLiked: Bool
    /// True, если пост сохранен на устройстве.
    let isStored: Bool
}

// MARK: - Mocks

extension Array where Element == Post {
    
    static var mock: [Post] {
        return []
    }
}

