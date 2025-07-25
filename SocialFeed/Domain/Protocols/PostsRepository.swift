/// Протокол, объединяющий функциональность получения, хранения и удаления постов
/// из локального или удалённого хранилища.
protocol PostsRepository: PostsProviding {
    /// Сохраняет пост в хранилище.
    ///
    /// - Parameters:
    ///   - post: Объект `Post`, который необходимо сохранить.
    ///   - completion: Замыкание, вызываемое по завершении операции. Возвращает результат с успехом или ошибкой.
    func store(post: Post, completion: @escaping (Result<Void, any Error>) -> Void)
    
    /// Удаляет пост из хранилища по указанному идентификатору.
    ///
    /// - Parameters:
    ///   - id: Уникальный идентификатор поста, подлежащего удалению.
    ///   - completion: Замыкание, вызываемое по завершении операции. Возвращает результат с успехом или ошибкой.
    func deletePost(by id: String, completion: @escaping (Result<Void, any Error>) -> Void)
}
