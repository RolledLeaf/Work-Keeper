import Foundation
import CoreData

final class StreetStore: NSObject, ObservableObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func createOrFetchStreet(name: String) -> Street {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            // Avoid creating an invalid Street (name is required)
            print("⚠️ createOrFetchStreet: empty name")
            // Return a temporary in-memory object (NOT saved) so callers can handle this case safely.
            return Street(context: context)
        }
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name ==[c] %@", trimmed),
            NSPredicate(format: "deletedAt == nil")
        ])
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                print("The street \(trimmed) already exists.")
                return existing
            } else {
                let street = Street(context: context)
                street.name = trimmed
                // Sync fields
                street.remoteId = nil
                street.deletedAt = nil
                street.updatedAt = Date()
                try context.save()
                return street
            }
        } catch {
            print("Error in createOrFetchStreet: \(error)")
            let street = Street(context: context)
            street.name = trimmed
            // Sync fields
            street.remoteId = nil
            street.deletedAt = nil
            street.updatedAt = Date()
            do {
                try context.save()
            } catch {
                print("Error saving street after fetch failure: \(error)")
            }
            return street
        }
    }
    
    func fetchStreets() -> [Street] {
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching streets: \(error)")
            return []
        }
    }

    func fetchStreets(matching name: String) -> [Street] {
       
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@ AND deletedAt == nil", trimmed)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching streets by name: \(error)")
            return []
        }
    }
    
    func fetchStreets( ascending: Bool) -> [Street] {
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        request.predicate = NSPredicate(format: "deletedAt == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: ascending)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching streets: \(error)")
            return []
        }
    }
    
    func createStreet(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            print("⚠️ createStreet: empty name")
            return
        }
        let street = Street(context: context)
        street.name = trimmed
        // Sync fields
        street.remoteId = nil
        street.deletedAt = nil
        street.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Error creating street: \(error)")
        }
    }
    
    func deleteStreet(street: Street) {
        // Soft delete for sync
        street.deletedAt = Date()
        street.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Unable to soft-delete street: \(error)")
        }
    }
    
    /// Permanent delete (debug / cleanup only)
    func purgeStreet(street: Street) {
        context.delete(street)
        do {
            try context.save()
        } catch {
            print("Unable to purge street: \(error)")
        }
    }
    
    func updateStreet(street: Street, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            print("⚠️ updateStreet: empty name")
            return
        }
        street.name = trimmed
        // Sync fields
        street.updatedAt = Date()

        do {
            try context.save()
        } catch {
            print("Error updating street: \(error)")
        }
    }
    
}
