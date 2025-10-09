import CoreData
import Foundation

struct PersistenceController {
    // Singleton instance - there's only one of these for the whole app
    static let shared = PersistenceController()
    
    // The Core Data container that holds everything (using CloudKit for sync)
    let container: NSPersistentCloudKitContainer
    
    // Initialize the Core Data stack
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "chorearoo")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [container] description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
            
            // Run data migration after stores are loaded
            if !inMemory {
                DataMigrationHelper.migrateExistingData(context: container.viewContext)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}
