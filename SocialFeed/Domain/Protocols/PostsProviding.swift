/// Протокол для получения данных модели `Post`.
protocol PostsProviding {

    /// Загружает список постов с поддержкой пагинации.
    ///
    /// - Parameters:
    ///   - page: Номер страницы, начиная с 0.
    ///   - perPage: Количество постов на странице.
    ///   - completion: Замыкание, вызываемое по завершении запроса. Возвращает результат с массивом `Post` или ошибкой.
    func fetchPosts(page: Int, perPage: Int, completion: @escaping FetchPostsCompletion)

    /// Загружает конкретный пост по его идентификатору.
    ///
    /// - Parameters:
    ///   - id: Уникальный идентификатор поста.
    ///   - completion: Замыкание, вызываемое по завершении запроса. Возвращает результат с объектом `Post` или ошибкой.
    func fetchPost(by id: String, completion: @escaping FetchPostCompletion)
}

/// Тип результата для запроса списка постов.
typealias FetchPostsCompletion = (Result<[PostSchema], any Error>) -> Void

/// Тип результата для запроса одного поста.
typealias FetchPostCompletion = (Result<PostSchema, any Error>) -> Void
