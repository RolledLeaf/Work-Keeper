import Foundation
import Combine

final class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    private let store = TaskStore()
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        tasks = store.fetchTasks()
    }
    
    func delete(_ task: Task) {
        store.deleteTask(task)
        loadTasks()
    }
}

final class CreateTaskViewModel: ObservableObject {
    @Published var scheduledAt: Date = Date()
    @Published var client: Client? = nil
    @Published var description: String = ""
    @Published var isRemote: Bool = false
    @Published var status: Status = .scheduled
    @Published var contractAmount: Double = 0
    @Published var cost: Double? = nil

    private let store = TaskStore()

    func saveTask() {
        guard let client else { return }
        store.createTask(
            scheduledAt: scheduledAt,
            client: client,
            description: description,
            isRemote: isRemote,
            status: status,
            contractAmount: contractAmount,
            cost: cost
        )
    }
}
