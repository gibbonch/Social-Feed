import CoreData

final class FavoriteManager: FavoriteManaging {
    
    private let contextProvider: ContextProvider
    
    init(contextProvider: ContextProvider) {
        self.contextProvider = contextProvider
    }
    
    // MARK: - Internal Methods
    
    func addPendingLike(_ postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.processPendingAction(postId: postId, liked: true, context: context)
        }
    }
    
    func addPendingUnlike(_ postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.processPendingAction(postId: postId, liked: false, context: context)
        }
    }
    
    func pendingActions(for postId: String) -> [FavoriteAction] {
        let request = PendingLikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "postId == %@", postId)
        let entities = (try? contextProvider.viewContext.fetch(request)) ?? []
        return entities.map {
            FavoriteAction(
                postId: $0.postId ?? "",
                timestamp: $0.timestamp ?? Date(),
                liked: $0.liked)
        }
    }
    
    func clearPendingActions() {
        contextProvider.performOnBackground { [weak self] context in
            self?.clearAllPendingActions(context: context)
        }
    }
    
    func deletePendingAction(for postId: String) {
        contextProvider.performOnBackground { [weak self] context in
            self?.deletePendingAction(postId: postId, context: context)
        }
    }
    
    // MARK: - Private Methods
    
    private func processPendingAction(postId: String, liked: Bool, context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchRequest(for: postId)
        
        do {
            let existingActions = try context.fetch(fetchRequest)
            
            if let existingAction = existingActions.first {
                if existingAction.liked == liked {
                    return
                } else {
                    context.delete(existingAction)
                    try context.save()
                    return
                }
            }
            
            let newAction = PendingLikeEntity(context: context)
            newAction.postId = postId
            newAction.timestamp = Date()
            newAction.liked = liked
            
            try context.save()
            
        } catch {
            print("Error processing pending action: \(error)")
        }
    }
    
    private func clearAllPendingActions(context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchAllRequest()
        
        do {
            let actions = try context.fetch(fetchRequest)
            actions.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Error clearing pending actions: \(error)")
        }
    }
    
    private func deletePendingAction(postId: String, context: NSManagedObjectContext) {
        let fetchRequest = PendingLikeEntity.fetchRequest(for: postId)
        
        do {
            let actions = try context.fetch(fetchRequest)
            actions.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Error deleting pending action: \(error)")
        }
    }
}

// MARK: - PendingLikeEntity Extension

extension PendingLikeEntity {
    
    static func fetchRequest(for postId: String) -> NSFetchRequest<PendingLikeEntity> {
        let request = PendingLikeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "postId == %@", postId)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchAllRequest() -> NSFetchRequest<PendingLikeEntity> {
        let request = PendingLikeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PendingLikeEntity.timestamp), ascending: true)]
        return request
    }
}
