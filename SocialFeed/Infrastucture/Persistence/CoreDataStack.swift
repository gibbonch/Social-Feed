import CoreData

protocol ContextProvider {
    
    var viewContext: NSManagedObjectContext { get }
    func performOnBackground(_ block: @escaping (NSManagedObjectContext) -> Void)
}

final class CoreDataStack: ContextProvider {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SocialFeedModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func performOnBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
