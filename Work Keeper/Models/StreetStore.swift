import Foundation
import CoreData

final class StreetStore: NSObject, ObservableObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func createOrFetchStreet(name: String) -> Street {
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            if let existing = try context.fetch(request).first {
                return existing
            } else {
                let street = Street(context: context)
                street.name = name
                try context.save()
                return street
            }
        } catch {
            print("Error in createOrFetchStreet: \(error)")
            let street = Street(context: context)
            street.name = name
            return street
        }
    }
    
    func fetchStreets() -> [Street] {
        let request: NSFetchRequest<Street> = Street.fetchRequest()
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
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", name)
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
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: ascending)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching streets: \(error)")
            return []
        }
    }
    
    func createStreet(name: String) {
        let street = Street(context: context)
        street.name = name
        
        do {
            try context.save()
        } catch {
            print("Error creating street: \(error)")
        }
    }
    
    func deleteStreet(street: Street) {
        context.delete(street)
        
        do {
            try context.save()
        } catch {
            print("Unable to delete street: \(error)")
        }
    }
    
    func updateStreet(street: Street, name: String) {
        street.name = name
        
        do {
            try context.save()
        } catch {
            print("Error updating street: \(error)")
        }
    }
    
}
