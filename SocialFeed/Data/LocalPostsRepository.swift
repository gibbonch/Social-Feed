import CoreData

/// Локальный репозиторий для работы с постами в Core Data.
final class LocalPostsRepository: PostsRepository {
    
    // MARK: - Private Properties
    
    /// Провайдер контекста Core Data для операций с базой данных.
    private let contextProvider: ContextProvider
    
    // MARK: - Lifecycle
    
    init(contextProvider: ContextProvider) {
        self.contextProvider = contextProvider
    }
    
    // MARK: - Internal Methods
    
    func store(post: Post, completion: @escaping (Result<Void, any Error>) -> Void) {
        contextProvider.performOnBackground { [weak self] context in
            guard let self = self else { return }
            
            do {
                try self.savePost(post, in: context)
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    func deletePost(by id: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        contextProvider.performOnBackground { [weak self] context in
            guard let self = self else { return }
            
            do {
                try self.deletePostEntity(with: id, in: context)
                completion(.success(()))
            } catch {
                context.rollback()
                completion(.failure(error))
            }
        }
    }
    
    func fetchPosts(page: Int, perPage: Int, completion: @escaping (Result<[Post], any Error>) -> Void) {
        contextProvider.performOnBackground { [weak self] context in
            guard let self = self else { return }
            
            do {
                let posts = try self.fetchPostsFromDatabase(page: page, perPage: perPage, in: context)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchPost(by id: String, completion: @escaping (Result<Post, any Error>) -> Void) {
        contextProvider.performOnBackground { [weak self] context in
            guard let self = self else { return }
            
            do {
                if let post = try self.fetchPostFromDatabase(with: id, in: context) {
                    completion(.success(post))
                } else {
                    completion(.failure(PostRepositoryError.postNotFound))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Сохраняет пост в Core Data.
    private func savePost(_ post: Post, in context: NSManagedObjectContext) throws {
        let entity = PostEntity(context: context)
        entity.postId = post.id
        entity.title = post.title
        entity.text = post.text
        entity.avatar = post.avatar
        entity.username = post.username
        entity.image = post.image
        entity.created = post.created
        entity.isLiked = post.isLiked
        entity.totalLikes = Int64(post.totalLikes)
        
        try context.save()
    }
    
    /// Удаляет пост из Core Data.
    private func deletePostEntity(with id: String, in context: NSManagedObjectContext) throws {
        let request = PostEntity.fetchRequest(for: id)
        
        let posts = try context.fetch(request)
        if let post = posts.first {
            context.delete(post)
            try context.save()
        }
    }
    
    /// Получает список постов из базы данных с пагинацией.
    private func fetchPostsFromDatabase(page: Int, perPage: Int, in context: NSManagedObjectContext) throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PostEntity.created), ascending: false)]
        request.fetchLimit = perPage
        request.fetchOffset = page * perPage
        
        let entities = try context.fetch(request)
        return entities.compactMap { mapEntityToPost($0) }
    }
    
    /// Получает конкретный пост из базы данных.
    private func fetchPostFromDatabase(with id: String, in context: NSManagedObjectContext) throws -> Post? {
        let request = PostEntity.fetchRequest(for: id)
        
        let entities = try context.fetch(request)
        guard let entity = entities.first else { return nil }
        
        return mapEntityToPost(entity)
    }
    
    /// Преобразует сущность Core Data в доменную модель.
    private func mapEntityToPost(_ entity: PostEntity) -> Post {
        return Post(
            id: entity.postId ?? "",
            username: entity.username ?? "",
            avatar: entity.avatar,
            title: entity.title ?? "",
            text: entity.text ?? "",
            image: entity.image ?? "",
            created: entity.created ?? Date(),
            totalLikes: Int(entity.totalLikes),
            isLiked: entity.isLiked,
            isStored: true
        )
    }
}

// MARK: - PostEntity Extensions

extension PostEntity {
    /// Создаёт fetch request для конкретного поста.
    static func fetchRequest(for id: String) -> NSFetchRequest<PostEntity> {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PostEntity.postId), id)
        request.fetchLimit = 1
        return request
    }
}

// MARK: - Error

enum PostRepositoryError: Error, LocalizedError {
    case postNotFound
    case savingFailed
    case deletionFailed
    
    var errorDescription: String? {
        switch self {
        case .postNotFound:
            return "Пост не найден"
        case .savingFailed:
            return "Ошибка сохранения поста"
        case .deletionFailed:
            return "Ошибка удаления поста"
        }
    }
}
