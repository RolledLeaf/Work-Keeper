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
                  phone: String
                  ) -> Client {
        
        let client = Client(context: context)
        client.id = UUID()
        client.firstName = firstName
        client.lastName = lastName
    client.address = NSSet(array: addresses)
        client.phone = phone
       
        
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
                                phone: phone
                                )
        }
    } catch {
        print("Error in createOrFetchClient: \(error)")
        return createClient(firstName: firstName,
                            lastName: lastName,
                            addresses: addresses,
                            phone: phone)
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
    
    func fetchClients(sortedBy keypath: String, ascending: Bool) -> [Client] {
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: keypath, ascending: ascending)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching clients: \(error)")
            return []
        }
    }
    
    func fetchClients(matching predicate: NSPredicate? = nil,
                      sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Client.firstName, ascending: true)],
                      limit: Int? = nil,
                      debug: Bool = false) -> [Client] {
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        if let limit = limit { request.fetchLimit = limit }
        if debug { print("[ClientStore] fetchClients(matching:) predicate:", predicate?.predicateFormat ?? "<none>") }
        do {
            return try context.fetch(request)
        } catch {
            print("❌ ClientStore.fetchClients(matching:) error:", error)
            return []
        }
    }
    
    func totalClientsCount(debug: Bool = false) -> Int {
        // Count clients who have at least one task with status scheduled or completed
        let request: NSFetchRequest<Client> = Client.fetchRequest()
        // Predicate: ANY tasks.statusString IN {"scheduled", "completed"}
      

        do {
            let count = try context.count(for: request)
            if debug { print("[ClientStore] totalClientsCount (scheduled|completed) =", count) }
            return count
        } catch {
            print("❌ Error counting clients", error)
            return 0
        }
    }
    
    

    
    func newClientsByMonth(
        year: Int,
        onlyCompleted: Bool = true,
        dateKey: String = "scheduledAt",
        debug: Bool = false
    ) -> [Int] {
        var result = Array(repeating: 0, count: 12)

        // Построим диапазон дат на год
        var cal = Calendar.current
        cal.timeZone = .current

        var startComp = DateComponents(); startComp.year = year; startComp.month = 1; startComp.day = 1
        var endComp   = DateComponents(); endComp.year = year + 1; endComp.month = 1; endComp.day = 1

        guard let startDate = cal.date(from: startComp),
              let endDate = cal.date(from: endComp) else {
            if debug { print("[ClientStore] ERROR: bad date range for year \(year)") }
            return result
        }

        // Fetch tasks in the year with client != nil (and optionally status)
        let req: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        req.predicate = {
            var preds: [NSPredicate] = [
                NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate),
                NSPredicate(format: "%K != nil", "client")
            ]
            if onlyCompleted {
                preds.append(NSPredicate(format: "statusString in %@", ["completed", "scheduled"]))
            }
            return NSCompoundPredicate(andPredicateWithSubpredicates: preds)
        }()
        // we only need the client relationship and date, but fetch objects for simplicity
        req.includesPropertyValues = true
        req.returnsObjectsAsFaults = false

        do {
            let tasks = try context.fetch(req)
            // Map clientID -> earliest date within year
            var firstDateByClient: [NSManagedObjectID: Date] = [:]

            for task in tasks {
                guard let client = task.client else { continue }
                let clientId = client.objectID
                // get date value
                let dateVal = task.value(forKey: dateKey) as? Date ?? task.scheduledAt
                guard let date = dateVal else { continue }

                if let existing = firstDateByClient[clientId] {
                    if date < existing {
                        firstDateByClient[clientId] = date
                    }
                } else {
                    firstDateByClient[clientId] = date
                }
            }

            // Now count by month of the earliest date
            for (_, firstDate) in firstDateByClient {
                let month = cal.component(.month, from: firstDate) // 1...12
                if month >= 1 && month <= 12 {
                    result[month - 1] += 1
                }
            }

            if debug {
                print("[ClientStore] newClientsByMonth year=\(year) onlyCompleted=\(onlyCompleted) counts=", result)
            }
            return result
        } catch {
            print("[ClientStore] newClientsByMonth fetch error:", error)
            return result
        }
    }
    
    func updateClient(_ client: Client,
                      firstName: String,
                      lastName: String?,
                      addresses: [Address],
                      phone: String
                      ) {
      
        client.firstName = firstName
        client.lastName = lastName
        client.address = NSSet(array: addresses)
        client.phone = phone
        
        
        do {
            try context.save()
        } catch {
            print("❌ Error updating client: \(error)")
        }
    }
    
func deleteClient(_ client: Client) {
    // 1) Удаляем адреса клиента (Address -> client является обязательной связью)
    if let addresses = client.address as? Set<Address> {
        for address in addresses {
            context.delete(address)
        }
    }

    // 2) Удаляем задачи клиента, если в модели Task.client стоит required
    if let tasks = client.tasks as? Set<TaskEntity> {
        for task in tasks {
            context.delete(task)
        }
    }

    // 3) Удаляем самого клиента
    context.delete(client)

    // 4) Сохраняем изменения
    do {
        try context.save()
    } catch {
        print("❌ Error deleting client: \(error)")
    }
}
    
    
    /// Fetch clients sorted by the number of completed tasks using a DB-side aggregation.
    /// Returns Client objects in the provided context ordered by completed tasks count.
    func fetchClientsSortedByCompletedCountDB(descending: Bool = true, limit: Int? = nil, debug: Bool = false) -> [Client] {
        // Build expression: count of tasks with status == "completed"
        let exprFormat = "SUBQUERY(tasks, $t, $t.statusString == %@).@count"
        let expr = NSExpression(format: exprFormat, "completed")

        let exprDesc = NSExpressionDescription()
        exprDesc.name = "completedCount"
        exprDesc.expression = expr
        exprDesc.expressionResultType = .integer32AttributeType

        // Request dictionary results containing objectID and the computed count
        let req = NSFetchRequest<NSDictionary>(entityName: "Client")
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["objectID", exprDesc]
        req.returnsDistinctResults = false

        // Sort by the computed value
        req.sortDescriptors = [NSSortDescriptor(key: "completedCount", ascending: !descending)]
        if let limit = limit { req.fetchLimit = limit }

        if debug { print("[ClientStore] fetchClientsSortedByCompletedCountDB predicate: <none>, sorting by completedCount \(descending ? "desc" : "asc")") }

        do {
            let rows = try context.fetch(req)
            var clients: [Client] = []
            clients.reserveCapacity(rows.count)

            for row in rows {
                if let objId = row["objectID"] as? NSManagedObjectID {
                    // obtain fault for object id in this context
                    if let client = try? context.existingObject(with: objId) as? Client {
                        clients.append(client)
                    }
                } else if let obj = row.object(forKey: "objectID") as? NSManagedObjectID {
                    if let client = try? context.existingObject(with: obj) as? Client {
                        clients.append(client)
                    }
                }
            }

            if debug {
                let sample = clients.prefix(10).map { c in
                    "\(c.firstName ?? "?") \(c.lastName ?? "") — completed:\(c.completedTasksCount)"
                }
                print("[ClientStore] fetchClientsSortedByCompletedCountDB sample:", sample)
            }

            return clients
        } catch {
            print("❌ ClientStore.fetchClientsSortedByCompletedCountDB error:", error)
            return []
        }
    }
}

extension Client {
    var hasAddress: Bool {
            guard let streetName = primaryAddress?.street?.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !streetName.isEmpty else {
                return false
            }
            return true
        }
    
    var addressesArray: [Address] {
        (address as? Set<Address>)?.sorted { $0.house ?? "" < $1.house ?? "" } ?? []
    }

    var primaryAddress: Address? {
        addressesArray.first(where: { $0.isPrimary })
    }
    
    var scheduledTasksCount: Int {
          (tasks as? Set<TaskEntity>)?
              .filter { $0.status == .scheduled }
              .count ?? 0
      }

      var completedTasksCount: Int {
          (tasks as? Set<TaskEntity>)?
              .filter { $0.status == .completed }
              .count ?? 0
      }

      var canceledTasksCount: Int {
          (tasks as? Set<TaskEntity>)?
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
           (tasks as? Set<TaskEntity>)?
               .compactMap { $0.totalAmount }
               .reduce(0, +) ?? 0
       }

      

       var totalTasksCount: Int {
           (tasks as? Set<TaskEntity>)?.count ?? 0
       }
    
   
}
