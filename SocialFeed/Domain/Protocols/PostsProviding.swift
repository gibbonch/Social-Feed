/// Протокол для получения данных о постах.
protocol PostsProviding {

    /// Загружает список постов с поддержкой пагинации.
    ///
    /// - Parameters:
    ///   - page: Номер страницы, начиная с 0.
    ///   - perPage: Количество постов на странице.
    ///   - completion: Замыкание, вызываемое по завершении запроса. Возвращает результат с массивом `Post` или ошибкой.
    func fetchPosts(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void)

    /// Загружает конкретный пост по его идентификатору.
    ///
    /// - Parameters:
    ///   - id: Уникальный идентификатор поста.
    ///   - completion: Замыкание, вызываемое по завершении запроса. Возвращает результат с объектом `Post` или ошибкой.
    func fetchPost(by id: String, completion: @escaping (Result<Post, any Error>) -> Void)
}
