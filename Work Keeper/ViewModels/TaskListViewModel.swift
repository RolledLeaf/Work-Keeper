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
    
   
    
    func scheduleTask(task: Task) {
        store.makeScheduled(task)
    }
    
    func cancelTask(task: Task) {
        store.makeCanceled(task)
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
    @Published var selectedPayment: PaymentType = .cash
    
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

        // Сначала создаём или подтягиваем клиента без адреса
        let client = clientStore.createOrFetchClient(
            firstName: firstName,
            lastName: lastName,
            addresses: [],
            phone: phone,
            comment: comment.isEmpty ? nil : comment
        )

        // Теперь создаём или подтягиваем адрес, уже зная client и isPrimary
        let address = addressStore.createOrFetchAddress(
            house: house,
            apartment: apartment,
            entrance: entrance,
            floor: floor,
            isPrivateHouse: isPrivateHouse,
            street: street,
            client: client,
            isPrimary: true
        )

        // link the address with the client
        client.addToAddress(address)

        // Create  task
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


final class CompleteTaskViewModel: ObservableObject {
    @Published var comment: String = ""
    @Published var contractAmountText: String = ""
    @Published var contractAmount: Double = 0
    @Published var costText: String = ""
    @Published var cost: Double = 0
    @Published var extraPaymentText: String = ""
    @Published var extraPayment: Double? = 0
    @Published var paymentType: PaymentType = .cash
    var finalAmount: Double {
        contractAmount + (extraPayment ?? 0) - cost
    }
    

    private let task: Task
    private let store = TaskStore()

    init(task: Task) {
        self.task = task
        self.comment = task.comment ?? ""
        self.cost = task.cost
        self.paymentType = PaymentType(rawValue: task.paymentType ?? "") ?? .cash
    }

    func complete() {
        store.makeCompleted(task,
                            comment: comment,
                            contractAmount: contractAmount,
                            cost: cost,
                            extraPayment: extraPayment,
                            paymentType: paymentType)
    }
}
