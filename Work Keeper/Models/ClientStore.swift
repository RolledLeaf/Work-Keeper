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
    
    
//    func distinctClientsCount(
//        year: Int,
//        month: Int? = nil,
//        onlyCompleted: Bool = true,
//        dateKey: String = "scheduledAt",
//        debug: Bool = false
//    ) -> Int {
//        // Построим диапазон дат
//        var cal = Calendar.current
//        cal.timeZone = .current
//
//        var start = DateComponents()
//        start.year = year
//        start.month = month ?? 1
//        start.day = 1
//
//        var end = DateComponents()
//        end.year = (month == nil) ? (year + 1) : year
//        end.month = (month == nil) ? 1 : (month! + 1)
//        end.day = 1
//
//        guard let startDate = cal.date(from: start),
//              let endDate = cal.date(from: end) else {
//            if debug { print("[ClientStore] ERROR: failed to build date range for year=\(year) month=\(String(describing: month))") }
//            return 0
//        }
//
//        if debug {
//            print("[ClientStore] distinctClientsCount year=\(year) month=\(String(describing: month)) onlyCompleted=\(onlyCompleted) dateKey=\(dateKey)")
//            print("[ClientStore] Date range: \(startDate) ..< \(endDate)")
//        }
//
//        // Preflight: посчитаем задачи разными срезами, без выборки всех объектов
//        if debug {
//            do {
//                // Всего задач
//                let allTasksReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
//                let allCount = try context.count(for: allTasksReq)
//
//                // С клиентом != nil
//                let withClientReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
//                withClientReq.predicate = NSPredicate(format: "%K != nil", "client")
//                let withClientCount = try context.count(for: withClientReq)
//
//                // В диапазоне дат по dateKey
//                let inRangeReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
//                inRangeReq.predicate = NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
//                let inRangeCount = try context.count(for: inRangeReq)
//
//                // В диапазоне дат + client != nil + (опционально) completed
//                let pred1 = NSPredicate(format: "%K != nil", "client")
//                let pred2 = NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
//                var preds = [pred1, pred2]
//                if onlyCompleted {
//                    preds.append(NSPredicate(format: "statusString in %@", ["completed", "scheduled"]))
//                }
//                let combinedReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
//                combinedReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: preds)
//                let combinedCount = try context.count(for: combinedReq)
//
//                print("[ClientStore] Preflight — all=\(allCount), withClient=\(withClientCount), inRange=\(inRangeCount), final=\(combinedCount)")
//
//                // Возьмём пару примеров для sanity-check
//                let sampleReq = NSFetchRequest<NSManagedObject>(entityName: "Task")
//                sampleReq.fetchLimit = 5
//                sampleReq.predicate = combinedReq.predicate
//                sampleReq.includesPropertyValues = true
//                sampleReq.propertiesToFetch = ["client", "statusString", dateKey]
//                let sample = try context.fetch(sampleReq)
//                let peek: [String] = sample.map { obj in
//                    let status = obj.value(forKey: "statusString") as? String ?? "?"
//                    let dateVal = obj.value(forKey: dateKey) as Any
//                    let clientObj = obj.value(forKey: "client")
//                    let clientDesc: String
//                    if let c = clientObj as? NSManagedObject { clientDesc = c.objectID.uriRepresentation().absoluteString } else { clientDesc = "nil" }
//                    return "status=\(status), date=\(dateVal), client=\(clientDesc)"
//                }
//                print("[ClientStore] Sample rows:", peek)
//            } catch {
//                print("[ClientStore] Preflight error:", error)
//            }
//        }
//
//        // Агрегатный запрос по Task: достаём только поле client и считаем DISTINCT
//        let request = NSFetchRequest<NSDictionary>(entityName: "Task")
//        request.resultType = .dictionaryResultType
//        request.propertiesToFetch = ["client"]
//        request.returnsDistinctResults = true
//
//        var predicates: [NSPredicate] = [
//            NSPredicate(format: "%K != nil", "client"),
//            NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
//        ]
//        if onlyCompleted {
//            predicates.append(NSPredicate(format: "statusString == %@", "completed"))
//        }
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//
//        if debug {
//            print("[ClientStore] DISTINCT predicate:", request.predicate?.predicateFormat ?? "<none>")
//        }
//
//        do {
//            let rows = try context.fetch(request)
//            if debug { print("[ClientStore] DISTINCT rows count:", rows.count) }
//            return rows.count // каждое словарик-значение — уникальный client
//        } catch {
//            print("❌ Error counting distinct clients:", error)
//            return 0
//        }
//    }
    
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
        let req: NSFetchRequest<Task> = Task.fetchRequest()
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
    if let tasks = client.tasks as? Set<Task> {
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
