import Foundation
import CoreData

final class ClientStore: NSObject, ObservableObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    

func createClient(firstName: String,
                  lastName: String?,
                  addresses: [Address],
                  phone: String,
                  comment: String?) -> Client {
        
        let client = Client(context: context)
        client.id = UUID()
        client.firstName = firstName
        client.lastName = lastName
    client.addresses = NSSet(array: addresses)
        client.phone = phone
        client.comment = comment
        
        do {
            try context.save()
        } catch {
            print("❌ Error saving client: \(error)")
        }
        
        return client
    }
                      
    func fetchClients() -> [Client] {
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Client.firstName, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching clients: \(error)")
            return []
        }
    }
    
    func updateClient(_ client: Client,
                      firstName: String,
                      lastName: String?,
                      addresses: [Address],
                      phone: String,
                      comment: String?) {
      
        client.firstName = firstName
        client.lastName = lastName
        client.addresses = NSSet(array: addresses)
        client.phone = phone
        client.comment = comment
        
        do {
            try context.save()
        } catch {
            print("❌ Error updating client: \(error)")
        }
    }
    
    func deleteClient(_ client: Client) {
        context.delete(client)
        do {
            try context.save()
        } catch {
            print("❌ Error deleting client: \(error)")
        }
    }
    
}
