import Foundation
import Combine

final class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var comment: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    
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
    @Published var shouldBlockEditing = false
    
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
        self.contractAmount = task.contractAmount
        self.contractAmountText = "\(Int(task.contractAmount))"
        self.comment = task.comment ?? ""
        self.cost = task.cost
        self.costText = "\(Int(task.cost))"
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

final class CancelTaskViewModel: ObservableObject {
    @Published var comment: String = ""

    private let task: Task
    private let store = TaskStore()

    init(task: Task) {
        self.task = task
        self.comment = task.comment ?? ""
    }

    func cancel() {
        store.makeCanceled(task, comment: comment)
    }
}

final class EditTaskViewModel: ObservableObject {
    // MARK: - Input properties bound to the UI
    @Published var scheduledAt: Date
    @Published var descriptionText: String
    @Published var comment: String
    @Published var isRemote: Bool
    @Published var status: Status
    @Published var contractAmountText: String
    @Published var costText: String
    @Published var extraPaymentText: String
    @Published var paymentType: PaymentType?
    // Client and address fields
    @Published var firstName: String
    @Published var lastName: String
    @Published var phoneNumber: String
    @Published var streetName: String
    @Published var house: String
    @Published var apartment: String
    @Published var entrance: String
    @Published var floorText: String
    @Published var isPrivateHouse: Bool
  
    @Published var shouldBlockEditing = false

    @Published var floor: Int16?
    @Published var contractAmount: Double
    @Published var cost: Double?
    @Published var extraPayment: Double?
    
    // MARK: - Computed Numeric Values
  
    
    
    
     var totalAmount: Double {
        contractAmount + (extraPayment ?? 0) - (cost ?? 0)
    }

    // MARK: - Internal
    private let task: Task
    private let store = TaskStore()

    // MARK: - Initialization
    init(task: Task) {
        self.task = task
        // Populate from existing Task
        self.scheduledAt = task.scheduledAt ?? Date()
        self.descriptionText = task.taskDescription ?? ""
        self.comment = task.comment ?? ""
        self.isRemote = task.isRemote
        self.status = Status(rawValue: task.statusString ?? "") ?? .scheduled
        self.contractAmountText = String(format: "%.0f", task.contractAmount)
        self.contractAmount = task.contractAmount
        if task.cost > 0 {
            self.costText = String(format: "%.0f", task.cost)
        } else {
            self.costText = ""
        }
        if task.extraPayment > 0 {
            self.extraPaymentText = String(format: "%.0f", task.extraPayment)
        } else {
            self.extraPaymentText = ""
        }
       

        // Populate client info
        self.firstName = task.client?.firstName ?? ""
        self.lastName = task.client?.lastName ?? ""
        self.phoneNumber = task.client?.phone ?? ""

        // Populate address info (primary address)
        if let address = (task.client?.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            self.streetName = address.street?.name ?? ""
            self.house = address.house ?? ""
            self.apartment = address.apartment ?? ""
            self.entrance = address.entrance ?? ""
            self.floorText = "\(address.floor)"
            self.isPrivateHouse = address.isPrivateHouse
        } else {
            self.streetName = ""
            self.house = ""
            self.apartment = ""
            self.entrance = ""
            self.floorText = ""
            self.isPrivateHouse = false
        }
    }

    // MARK: - Public methods
    /// Apply changes and save to Core Data
    func update() {
        // Update client properties
        if let client = task.client {
            client.firstName = firstName
            client.lastName = lastName
            client.phone = phoneNumber
        }

        // Update primary address
        if let address = (task.client?.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            address.street?.name = streetName
            address.house = house
            address.apartment = apartment
            address.entrance = entrance
            address.floor = Int16(floorText) ?? 0
            address.isPrivateHouse = isPrivateHouse
        }

        store.updateTask(
            task,
            scheduledAt: scheduledAt,
            client: task.client!,
            taskDescription: descriptionText.isEmpty ? nil : descriptionText,
            comment: comment.isEmpty ? nil : comment,
            isRemote: isRemote,
            status: status,
            contractAmount: contractAmount,
            extraPayment: extraPayment,
            paymentType: paymentType ?? .none,
            cost: cost
        )
    }
}

