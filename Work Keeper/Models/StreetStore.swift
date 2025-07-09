import Foundation
import CoreData

final class StreetStore: NSObject, ObservableObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchStreets() -> [Street] {
        let request: NSFetchRequest<Street> = Street.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching streets: \(error)")
            return []
        }
    }
    
    func createStreet(name: String) {
        guard !name.isBlank else { return }
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
        guard !name.isBlank else { return }
        street.name = name
        
        do {
            try context.save()
        } catch {
            print("Error updating street: \(error)")
        }
    }
    
}
