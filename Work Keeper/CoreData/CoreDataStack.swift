import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "KeeperDB")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                assertionFailure("⚠️ Failed to load persistent stores: \(error)")
                print("❌ Error loading persistent stores: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy 

        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
     func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
}

//CloudKit Persistent Container
//final class CoreDataStack {
//    
//    static let shared = CoreDataStack()
//    
//    private init() {}
//    
//    lazy var persistentContainer: NSPersistentCloudKitContainer = {
//        // 1) Use CloudKit-enabled persistent container
//        let container = NSPersistentCloudKitContainer(name: "KeeperDB")
//
//        // 2) Configure the store description
//        guard let description = container.persistentStoreDescriptions.first else {
//            fatalError("No persistent store description found")
//        }
//
//        // 3) Set your CloudKit container identifier (replace with your real one from Capabilities)
//        //    Example: "iCloud.com.your.bundle.id"
//        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "ru.rolledleaf.Work-Keeper")
//        description.cloudKitContainerOptions = options
//
//        // 4) Enable history tracking & remote change notifications for reliable syncing
//        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//
//        // 5) Load stores
//        container.loadPersistentStores { storeDescription, error in
//            if let error = error as NSError? {
//                assertionFailure("⚠️ Failed to load persistent stores: \(error), userInfo: \(error.userInfo)")
//                print("❌ Error loading persistent stores: \(error.localizedDescription)")
//            } else {
//                print("✅ Persistent store loaded: \(storeDescription)\nCloudKit container: \(options.containerIdentifier)")
//            }
//        }
//
//        // 6) Merge policies and automatic merges from background/CloudKit
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.transactionAuthor = "main"
//
//        return container
//    }()
//    
//    var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//    
//     func saveContext() {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                print("❌ Failed to save context: \(error)")
//            }
//        }
//    }
//}
