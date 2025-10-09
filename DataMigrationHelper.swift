import CoreData
import Foundation

struct DataMigrationHelper {
    static func migrateExistingData(context: NSManagedObjectContext) {
        let childFetchRequest: NSFetchRequest<Child> = Child.fetchRequest()
        
        do {
            let children = try context.fetch(childFetchRequest)
            
            // Set default weekly cap for any children that don't have one
            for child in children {
                if child.weeklyCap == 0 {
                    child.weeklyCap = 10.0
                }
            }
            
            try context.save()
            print("✅ Data migration complete: Set weekly cap for \(children.count) children")
        } catch {
            print("❌ Error migrating data: \(error)")
        }
    }
}
