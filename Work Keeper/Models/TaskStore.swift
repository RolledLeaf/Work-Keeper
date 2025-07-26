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
        task.cost = cost ?? 0
        task.extraPayment = extraPayment ?? 0
        task.paymentType = paymentType.rawValue
        
        // Recalculate total
        task.totalAmount = contractAmount + (extraPayment ?? 0) - (cost ?? 0)
        
        // Save changes
        do {
            try context.save()
        } catch {
            print("❌ Error updating task: \(error)")
        }
    }
}


