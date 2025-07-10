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
    @Published var streetName: String = ""
    @Published var house: String = ""
    @Published var apartment: String = ""
    @Published var entrance: String = ""
    @Published var floor: Int16 = 0
    @Published var floorText: String = ""
    @Published var isPrivateHouse: Bool = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var comment: String = ""
    @Published var description: String = ""
    @Published var isRemote: Bool = false
    @Published var status: Status = .scheduled
    @Published var contractAmountText: String = ""
    @Published var contractAmount: Double = 0
    @Published var cost: Double? = nil
    @Published var costText: String = ""
    
    var totalAmount: Double {
        contractAmount - (cost ?? 0)
    }
    
    @Published private var roomType = "кв"
    @Published private var entranceType = "под"

    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    private let clientStore = ClientStore()
    private let taskStore = TaskStore()

    func saveTask() {
        let street = streetStore.createOrFetchStreet(name: streetName)
        let address = addressStore.createOrFetchAddress(
            house: house,
            apartment: apartment,
            entrance: entrance,
            floor: floor,
            isPrivateHouse: isPrivateHouse,
            street: street
        )
        let client = clientStore.createOrFetchClient(
            firstName: firstName,
            lastName: lastName,
            addresses: [address],
            phone: phone,
            comment: comment.isEmpty ? nil : comment
        )
        taskStore.createTask(
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
