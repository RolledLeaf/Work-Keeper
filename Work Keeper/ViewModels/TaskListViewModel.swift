import Foundation
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var comment: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var tasksCount: Int = 0
    @Published var canceledTasksCount: Int = 0
    
    var groupedTasksByDate: [Date: [Task]] {
        Dictionary(grouping: tasks) { task in
            let date = task.scheduledAt ?? Date.distantPast
            return Calendar.current.startOfDay(for: date) // normalize to day
        }
    }
    
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
        loadTasks()
    }
    
    // MARK: - Statistics Methods
    
    @discardableResult
    func countTasks(year: Int,
                    month: Int?,
                    status: Status?,
                    dateKey: String = "scheduledAt",
                    debug: Bool = false) -> Int {
        tasksCount = store.countTasks(year: year,
                                      month: month,
                                      status: status,
                                      dateKey: dateKey,
                                      debug: debug
        )
        return tasksCount
    }
    
    func loadAlltasksCount(debug: Bool = false) {
        tasksCount = store.totalTasksCount()
        print("loaded all clients count: \(tasksCount)")
    }
    
    func loadAllCanceledTasksCount(debug: Bool = false) {
        canceledTasksCount = store.totalCanceled(debug: debug)
        print("loaded all canceled clients count: \(canceledTasksCount)")
    }
    
    // MARK: - Convenience counters
    @discardableResult
    func completedCount(year: Int,
                        month: Int?,
                        dateKey: String = "scheduledAt",
                        debug: Bool = false) -> Int {
        countTasks(year: year, month: month, status: .completed, dateKey: dateKey, debug: debug)
    }

    @discardableResult
    func canceledCount(year: Int,
                       month: Int?,
                       dateKey: String = "scheduledAt",
                       debug: Bool = false) -> Int {
        countTasks(year: year, month: month, status: .canceled, dateKey: dateKey, debug: debug)
    }
    
    
 
}

final class CreateTaskViewModel: ObservableObject {
    @Published var scheduledAt: Date = Date()
    @Published var streetName: String = ""
    @Published var house: String = ""
    @Published var apartment: String = ""
    @Published var entrance: String = ""
    @Published var floor: String = ""
    @Published var isPrivateHouse: Bool = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    // Храним только цифры (10-значный российский NSN)
    @Published var phoneDigits: String = ""
    @Published var comment: String = ""
    @Published var description: String = ""
    @Published var isRemote: Bool = false
    @Published var status: Status = .scheduled
    @Published var contractAmountText: String = ""
    @Published var contractAmount: Double = 0
    @Published var cost: Double? = nil
    @Published var costText: String = ""
    @Published var selectedPayment: PaymentType = .none
    
    @Published var remoteEdditingBlock = false
    @Published var privateHouseBlock = false
    
    @Published var shouldBlockRemote = false
    @Published var shouldBlockPrivate = false
    
    
    @Published  var roomType: String?
    @Published  var entranceType: String?
    
    var totalAmount: Double {
        contractAmount - (cost ?? 0)
    }
    
 
    
   
    
    let roomTypes = ["кв.", "оф.", "каб."]
    let entranceTypes = ["под.", "вход."]
    
    

    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    private let clientStore = ClientStore()
    private let taskStore = TaskStore()
    
  

    func saveTask() {
        let street = streetStore.createOrFetchStreet(name: streetName)

        let normalizedPhone = phoneDigits.isEmpty ? nil : "+7" + phoneDigits
        let client = clientStore.createOrFetchClient(
            firstName: firstName,
            lastName: lastName,
            addresses: [],
            phone: normalizedPhone ?? "",
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
            isPrimary: true,
            roomType: roomType ?? "кв.",
            entranceType: entranceType ?? "под."
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
        print("""
         ✅ Задание успешно создано:
         📆 Дата: \(scheduledAt)
         👤 Клиент: \(firstName) \(lastName), телефон: \(maskRU(fromDigits: phoneDigits))
         🏠 Адрес: \(streetName), дом: \(house), \(roomType ?? "") \(apartment), \(entranceType ?? "") \(entrance), этаж \(floor)
         📝 Описание: \(description)
         💬 Комментарий: \(comment)
         🌍 Удалённо: \(isRemote ? "Да" : "Нет")
         💵 Сумма по договору: \(contractAmount)
         💸 Издержки: \(cost ?? 0)
         Тип помещения: \(roomType ?? "")
         Тип Входа: \(entranceType ?? "")
         🧾 Статус: \(status.rawValue)
         """)
    }
    
    private func maskRU(fromDigits s: String) -> String {
        if s.isEmpty { return "" }
        var result = "+7"
        let chars = Array(s)

        result += "("
        let a = min(3, chars.count)
        result += String(chars[0..<a])
        if chars.count < 3 { return result }

        result += ")"
        let b = min(3, chars.count - 3)
        if b > 0 { result += String(chars[3..<(3 + b)]) }
        if chars.count < 6 { return result }

        result += "-"
        let c = min(2, chars.count - 6)
        if c > 0 { result += String(chars[6..<(6 + c)]) }
        if chars.count < 8 { return result }

        result += "-"
        let d = min(2, chars.count - 8)
        if d > 0 { result += String(chars[8..<(8 + d)]) }

        return result
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
    @Published var phoneDigits: String = ""
    @Published var phoneNumber: String
    @Published var streetName: String
    @Published var house: String
    @Published var apartment: String
    @Published var entrance: String
    @Published var floor: String
    @Published var isPrivateHouse: Bool
  
    @Published var remoteEdditingBlock = false
    @Published var privateHouseBlock = false
    
    @Published var shouldBlockRemote = false
    @Published var shouldBlockPrivate = false

  
    @Published var contractAmount: Double
    @Published var cost: Double?
    @Published var extraPayment: Double?
    
    
    @Published  var roomType: String?
    @Published  var entranceType: String?
    
    let roomTypes = ["кв.", "оф.", "каб."]
    let entranceTypes = ["под.", "вход."]
    
    // MARK: - Computed Numeric Values

     var totalAmount: Double {
        contractAmount + (extraPayment ?? 0) - (cost ?? 0)
    }

    // MARK: - Internal
    private let task: Task
    private let store = TaskStore()

    // MARK: - Initialization
    init(task: Task) {
        let rawPhone = task.client?.phone ?? ""
        let digitsAll = rawPhone.filter { $0.isNumber }
        var nsn = digitsAll
        if nsn.hasPrefix("7") { nsn.removeFirst() }     // убираем +7
        if nsn.count > 10 { nsn = String(nsn.suffix(10)) }
        self.phoneDigits = nsn
        self.phoneNumber = rawPhone // можно не использовать во View
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
            self.entrance = address.entrance ?? "?"
            self.floor = address.floor ?? "?"
            self.isPrivateHouse = address.isPrivateHouse
            self.roomType = address.roomType ?? "кв."
            self.entranceType = address.entranceType ?? "под."
        } else {
            self.streetName = ""
            self.house = ""
            self.apartment = ""
            self.entrance = ""
            self.floor = ""
            self.isPrivateHouse = false
            self.roomType =  ""
            self.entranceType = ""
        }
    }

    // MARK: - Public methods
    /// Apply changes and save to Core Data
    func update() {
        // Update client
        guard let client = task.client else {
            print("❌ Ошибка: у задачи отсутствует клиент")
            return
        }

        // Обновляем клиента и адрес, как и раньше
        client.firstName = firstName
        client.lastName = lastName
        client.phone = phoneDigits.isEmpty ? "" : "+7" + phoneDigits

        if let address = (client.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            address.street?.name = streetName
            address.house = house
            address.apartment = apartment
            address.entrance = entrance
            address.floor = floor
            address.isPrivateHouse = isPrivateHouse
            address.entranceType = entranceType
            address.roomType = roomType
        }

        // безопасный вызов updateTask
        store.updateTask(
            task,
            scheduledAt: scheduledAt,
            client: client,
            taskDescription: descriptionText.isEmpty ? nil : descriptionText,
            comment: comment.isEmpty ? nil : comment,
            isRemote: isRemote,
            status: status,
            contractAmount: contractAmount,
            extraPayment: extraPayment,
            paymentType: paymentType ?? .none,
            cost: cost
        )
        
        print("""
         ✅ Задание успешно изменено:
         📆 Дата: \(scheduledAt)
         👤 Клиент: \(firstName) \(lastName), телефон: \(maskRU(fromDigits: phoneDigits))
                🏠 Адрес: \(streetName), дом: \(house), \(roomType ?? "") \(apartment), \(entranceType ?? "") \(entrance), этаж \(floor)
         📝 Описание: \(descriptionText)
         💬 Комментарий: \(comment)
         🌍 Удалённо: \(isRemote ? "Да" : "Нет")
         💵 Сумма по договору: \(contractAmount)
         💸 Издержки: \(cost ?? 0)
         Тип помещения: \(roomType ?? "")
                 Тип Входа: \(entranceType ?? "")
         🧾 Статус: \(status)
         """)
    }
    
    private func maskRU(fromDigits s: String) -> String {
        if s.isEmpty { return "" }
        var result = "+7"
        let chars = Array(s)

        result += "("
        let a = min(3, chars.count)
        result += String(chars[0..<a])
        if chars.count < 3 { return result }

        result += ")"
        let b = min(3, chars.count - 3)
        if b > 0 { result += String(chars[3..<(3 + b)]) }
        if chars.count < 6 { return result }

        result += "-"
        let c = min(2, chars.count - 6)
        if c > 0 { result += String(chars[6..<(6 + c)]) }
        if chars.count < 8 { return result }

        result += "-"
        let d = min(2, chars.count - 8)
        if d > 0 { result += String(chars[8..<(8 + d)]) }

        return result
    }
}
