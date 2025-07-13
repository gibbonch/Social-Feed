import CoreData

/// Управляет отложенными действиями лайков/анлайков с использованием Core Data
final class PendingLikeActionsManager: PendingLikeActionsManaging {
    
    // MARK: - Private Properties
    
    private let contextProvider: ContextProvider
    
    // MARK: - Initialization
    
    init(contextProvider: ContextProvider) {
        self.contextProvider = contextProvider
    }
    
    // MARK: - Internal Methods
    
    func queueLikeAction(for postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.processLikeAction(postId: postId, isLiked: true, context: context)
        }
    }
    
    func queueUnlikeAction(for postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.processLikeAction(postId: postId, isLiked: false, context: context)
        }
    }
    
    func pendingActions(for postId: String) -> [PendingLikeAction] {
        let request = PendingLikeEntity.fetchRequest(for: postId)
        let entities = (try? contextProvider.viewContext.fetch(request)) ?? []
        
        return entities.map { entity in
            PendingLikeAction(
                postId: entity.postId ?? "",
                timestamp: entity.timestamp ?? Date(),
                isLiked: entity.liked
            )
        }
    }
    
    func clearAllPendingActions() {
        contextProvider.performOnBackground { [weak self] context in
            self?.removeAllPendingActions(in: context)
        }
    }
    
    func removePendingAction(for postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.removePendingAction(postId: postId, in: context)
        }
    }
    
    // MARK: - Private Methods
    
    private func processLikeAction(postId: String, isLiked: Bool, context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchRequest(for: postId)
        
        do {
            let existingActions = try context.fetch(fetchRequest)
            
            if let existingAction = existingActions.first {
                if existingAction.liked == isLiked {
                    return
                }
                else {
                    context.delete(existingAction)
                    try context.save()
                    return
                }
            }
            
            let newAction = PendingLikeEntity(context: context)
            newAction.postId = postId
            newAction.timestamp = Date()
            newAction.liked = isLiked
            
            try context.save()
            
        } catch {
            print("Ошибка обработки действия лайка для поста \(postId): \(error)")
        }
    }
    
    /// Удаляет все отложенные действия из базы данных
    private func removeAllPendingActions(in context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchAllRequest()
        
        do {
            let actions = try context.fetch(fetchRequest)
            actions.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Ошибка удаления всех отложенных действий: \(error)")
        }
    }
    
    /// Удаляет отложенное действие для конкретного поста
    private func removePendingAction(postId: String, in context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchRequest(for: postId)
        
        do {
            let actions = try context.fetch(fetchRequest)
            actions.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Ошибка удаления отложенного действия для поста \(postId): \(error)")
        }
    }
}

// MARK: - PendingLikeEntity Extension

extension PendingLikeEntity {
    
    /// Создает fetch request для конкретного поста
    static func fetchRequest(for postId: String) -> NSFetchRequest<PendingLikeEntity> {
        let request = PendingLikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PendingLikeEntity.postId), postId)
        request.fetchLimit = 1
        return request
    }
    
    /// Создает fetch request для всех отложенных действий
    static func fetchAllRequest() -> NSFetchRequest<PendingLikeEntity> {
        let request = PendingLikeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PendingLikeEntity.timestamp), ascending: true)]
        return request
    }
}
