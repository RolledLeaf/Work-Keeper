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
    client.address = NSSet(array: addresses)
        client.phone = phone
        client.comment = comment
        
        do {
            try context.save()
        } catch {
            print("❌ Error saving client: \(error)")
        }
        
        return client
    }
                      
func createOrFetchClient(firstName: String,
                         lastName: String?,
                         addresses: [Address],
                         phone: String,
                         comment: String?) -> Client {
    
    let request: NSFetchRequest<Client> = Client.fetchRequest()
    request.predicate = NSPredicate(format: "firstName == %@ AND phone == %@", firstName, phone)
    request.fetchLimit = 1
    
    do {
        if let existing = try context.fetch(request).first {
            return existing
        } else {
            return createClient(firstName: firstName,
                                lastName: lastName,
                                addresses: addresses,
                                phone: phone,
                                comment: comment)
        }
    } catch {
        print("Error in createOrFetchClient: \(error)")
        return createClient(firstName: firstName,
                            lastName: lastName,
                            addresses: addresses,
                            phone: phone,
                            comment: comment)
    }
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
        client.address = NSSet(array: addresses)
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

extension Client {
    var addressesArray: [Address] {
        (address as? Set<Address>)?.sorted { $0.house ?? "" < $1.house ?? "" } ?? []
    }

    var primaryAddress: Address? {
        addressesArray.first(where: { $0.isPrimary })
    }
    
    var scheduledTasksCount: Int {
          (tasks as? Set<Task>)?
              .filter { $0.status == .scheduled }
              .count ?? 0
      }

      var completedTasksCount: Int {
          (tasks as? Set<Task>)?
              .filter { $0.status == .completed }
              .count ?? 0
      }

      var canceledTasksCount: Int {
          (tasks as? Set<Task>)?
              .filter { $0.status == .canceled }
              .count ?? 0
      }
    
    var formattedAddress: String {
        guard let address = address?.allObjects.first as? Address else { return "Адрес не указан" }
        return "\(address.street?.name ?? "") \(address.house ?? "")"
    }
    
  
    
    
    var apartmentNumber: String {
        guard let address = address?.allObjects.first as? Address else { return "?" }
        return address.apartment ?? "?"
    }
    
    var entranceNumber: String {
        guard let address = address?.allObjects.first as? Address else { return "?" }
        return address.entrance ?? "?"
    }
    
    var floorNumber: String {
        guard let address = address?.allObjects.first as? Address else { return "?" }
        return address.floor ?? "?"
    }
    
    var totalIncome: Double {
           (tasks as? Set<Task>)?
               .compactMap { $0.totalAmount }
               .reduce(0, +) ?? 0
       }

      

       var totalTasksCount: Int {
           (tasks as? Set<Task>)?.count ?? 0
       }
    
   
}
