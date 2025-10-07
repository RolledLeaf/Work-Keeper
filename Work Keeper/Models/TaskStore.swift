import Foundation
import CoreData

final class TaskStore: NSObject, ObservableObject {
    
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    
    func createTask(scheduledAt: Date,
                    client: Client,
                    description: String?,
                    isRemote: Bool,
                    status: Status,
                    contractAmount: Double,
                    cost: Double?) -> Task {
        
        
        
        let task = Task(context: context)
        task.id = UUID()
        task.scheduledAt = scheduledAt
        task.client = client
        task.taskDescription = description
        task.isRemote = isRemote
        task.statusString = status.rawValue
        task.contractAmount = contractAmount
        task.cost = cost ?? 0
        task.totalAmount = contractAmount - (cost ?? 0)
        
        do {
            try context.save()
        } catch {
            print("❌ Error saving task: \(error)")
        }
        
        return task
    }
    
   
    
    func makeCompleted(_ task: Task,
                       comment: String?,
                       contractAmount: Double,
                       cost: Double?,
                       extraPayment: Double?,
                       paymentType: PaymentType) {
        task.status = .completed
        task.comment = comment
        task.contractAmount = contractAmount
        task.cost = cost ?? 0
        task.extraPayment = extraPayment ?? 0
        task.paymentType = paymentType.rawValue
        task.totalAmount = task.contractAmount + (extraPayment ?? 0) - (cost ?? 0)
        do {
            try context.save()
        } catch {
            print("❌ Error completing task: \(error)")
        }
    }
    
    func makeScheduled(_ task: Task) {
        task.status = .scheduled
        task.paymentType = .none
        do {
            try context.save()
        } catch {
            print("❌ Error changing status of task: \(error)")
        }
    }
    
    func makeCanceled(_ task: Task, comment: String?) {
        task.status = .canceled
        task.comment = comment
        task.contractAmount = 0
        task.cost = 0
        task.totalAmount = 0
        task.paymentType = .none
        do {
            try context.save()
        } catch {
            print("❌ Error canceling task: \(error)")
        }
    }
    
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.scheduledAt, ascending: true)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching tasks: \(error)")
            return []
        }
    }
     
    func deleteTask(_ task: Task) {
        context.delete(task)
        do {
            try context.save()
        } catch {
            print("❌ Error deleting task: \(error)")
        }
    }
    
    func updateTask(_ task: Task,
                    scheduledAt: Date,
                    client: Client,
                    taskDescription: String?,
                    comment: String?,
                    isRemote: Bool,
                    status: Status,
                    contractAmount: Double,
                    extraPayment: Double?,
                    paymentType: PaymentType,
                    cost: Double?) {
        
        // Update core fields
        task.scheduledAt = scheduledAt
        task.client = client
        task.taskDescription = taskDescription
        task.comment = comment
        task.isRemote = isRemote
        
        // Update status
        task.statusString = status.rawValue
        
        // Update financials
        task.contractAmount = contractAmount
        if let cost = cost {
            task.cost = cost
        }
        if let extra = extraPayment {
            task.extraPayment = extra
        }
        task.paymentType = paymentType.rawValue
        
        // Recalculate total
        task.totalAmount = task.contractAmount + task.extraPayment - task.cost
        
        // Save changes
        do {
            try context.save()
        } catch {
            print("❌ Error updating task: \(error)")
        }
    }
    
    
    // MARK: - Stats / Queries by Status & Date

    /// Подсчёт количества задач за период, с фильтром по статусу (опционально)
    /// - Parameters:
    ///   - year: Год периода
    ///   - month: Месяц 1...12; если nil — берётся весь год
    ///   - status: Фильтр по статусу (например, .completed / .canceled). Если nil — любой статус
    ///   - dateKey: По какому полю даты фильтруем (по умолчанию scheduledAt)
    ///   - debug: Печатать ли подробные логи
    func countTasks(
        year: Int,
        month: Int? = nil,
        status: Status? = nil,
        dateKey: String = "scheduledAt",
        debug: Bool = false
    ) -> Int {
        var cal = Calendar.current
        cal.timeZone = .current

        var start = DateComponents(); start.year = year; start.month = month ?? 1; start.day = 1
        var end   = DateComponents(); end.year   = (month == nil) ? (year + 1) : year
        end.month = (month == nil) ? 1 : (month! + 1); end.day = 1

        guard let startDate = cal.date(from: start), let endDate = cal.date(from: end) else { return 0 }

        let request: NSFetchRequest<Task> = Task.fetchRequest()

        var predicates: [NSPredicate] = [
            NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
        ]
        if let status { predicates.append(NSPredicate(format: "statusString == %@", status.rawValue)) }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        if debug {
            print("[TaskStore] countTasks year=\(year) month=\(String(describing: month)) status=\(status?.rawValue ?? "<any>") dateKey=\(dateKey)")
            print("[TaskStore] predicate:", request.predicate?.predicateFormat ?? "<none>")
        }
        do { return try context.count(for: request) } catch { print("❌ countTasks error:", error); return 0 }
    }

    /// Выборка задач за период с опциональным фильтром статуса (для списков/деталей)
    func fetchTasks(
        year: Int,
        month: Int? = nil,
        status: Status? = nil,
        dateKey: String = "scheduledAt",
        limit: Int? = nil,
        debug: Bool = false
    ) -> [Task] {
        var cal = Calendar.current
        cal.timeZone = .current

        var start = DateComponents(); start.year = year; start.month = month ?? 1; start.day = 1
        var end   = DateComponents(); end.year   = (month == nil) ? (year + 1) : year
        end.month = (month == nil) ? 1 : (month! + 1); end.day = 1

        guard let startDate = cal.date(from: start), let endDate = cal.date(from: end) else { return [] }

        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.scheduledAt, ascending: true)]

        var predicates: [NSPredicate] = [
            NSPredicate(format: "%K >= %@ AND %K < %@", dateKey, startDate as NSDate, dateKey, endDate as NSDate)
        ]
        if let status { predicates.append(NSPredicate(format: "statusString == %@", status.rawValue)) }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        if let limit { request.fetchLimit = limit }

        if debug {
            print("[TaskStore] fetchTasks year=\(year) month=\(String(describing: month)) status=\(status?.rawValue ?? "<any>") dateKey=\(dateKey) limit=\(String(describing: limit))")
            print("[TaskStore] predicate:", request.predicate?.predicateFormat ?? "<none>")
        }

        do { return try context.fetch(request) } catch { print("❌ fetchTasks error:", error); return [] }
    }

    /// Удобные хелперы для completed / canceled
    func completedCount(year: Int, month: Int? = nil, dateKey: String = "scheduledAt") -> Int {
        countTasks(year: year, month: month, status: .completed, dateKey: dateKey)
    }
    func canceledCount(year: Int, month: Int? = nil, dateKey: String = "scheduledAt") -> Int {
        countTasks(year: year, month: month, status: .canceled, dateKey: dateKey)
    }
    
    @discardableResult
    func totalTasksCount(debug: Bool = false) -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let count = try context.count(for: request)
            if debug { print("[TaskStore] totalTaskCount =", count) }
            return count
        } catch {
            print("❌ Error counting tasks:", error)
            return 0
        }
    }
    
    @discardableResult
    func totalCanceled(debug: Bool = false) -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "statusString == %@", Status.canceled.rawValue)
        do {
            let count = try context.count(for: request)
            if debug { print("[TaskListViewModel] totalCanceled =", count) }
            return count
        } catch {
            print("❌ totalCanceled error:", error)
            return 0
        }
    }
}


extension Task {
    var status: Status {
        get {
            Status(rawValue: statusString ?? "") ?? .scheduled
        }
        set {
            statusString = newValue.rawValue
        }
    }
}


extension Task {
    var payment: PaymentType {
        get { PaymentType(rawValue: paymentType ?? "" ) ?? .none }
        set { paymentType = newValue.rawValue }
    }
    
   
}
