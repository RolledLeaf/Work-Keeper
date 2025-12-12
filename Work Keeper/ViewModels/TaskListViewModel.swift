import Foundation
import CoreData
import Combine

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var yearCompletedTasksCount: Int = 0
    @Published var yearCanceledTasksCount: Int = 0
    @Published var monthCompletedTasksCount: Int = 0
    @Published var monthCanceledTasksCount: Int = 0
    @Published var monthlyCompletedTasksCounts: [Int] = Array(repeating: 0, count: 12)
    @Published var monthlyCanceledTasksCounts: [Int] = Array(repeating: 0, count: 12)
    @Published var searchText = ""
    @Published var comment: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var tasksCount: Int = 0
    @Published var canceledTasksCount: Int = 0
    @Published var selectedStatuses: [Status]? = nil
    @Published var lastScheduledTaskDescription: String? = nil
    @Published var didScheduleTask: Bool = false
    @Published var selectedFilters: Set<TaskStatus> = []
    @Published var defaultPaymentType: PaymentType = .none
    
    private let store = TaskStore()
    private var cancelables = Set<AnyCancellable>()

    func scheduleTask(_ task: TaskEntity, at date: Date) {
        task.scheduledAt = date
        store.makeScheduled(task, paymentType: defaultPaymentType)
        lastScheduledTaskDescription = task.taskDescription
        didScheduleTask = true
        print("Task \(String(describing: task.taskDescription)) rescheduled to \(date)")
    }
    
    
    
    var groupedTasksByDate: [Date: [TaskEntity]] {
        Dictionary(grouping: tasks) { task in
            let date = task.scheduledAt ?? Date.distantPast
            return Calendar.current.startOfDay(for: date)
        }
    }
 
    init() {
        // initial load
        loadTasks()
        // Debounce searchText changes and apply combined filters after user stops typing
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applyFiltersAsync()
            }
            .store(in: &cancelables)

        // React to status selection changes immediately
        $selectedStatuses
            .sink { [weak self] _ in
                self?.applyFiltersAsync()
            }
            .store(in: &cancelables)
    }

    func calculateDailyIncome(for date: Date, debug: Bool = false) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 0
        }

        // фильтруем только завершённые задания за день
        let dailyTasks = tasks.filter { task in
            guard
                task.status == .completed,
                let taskDate = task.scheduledAt
            else { return false }

            return taskDate >= startOfDay && taskDate < endOfDay
        }

        // суммируем доход
        let total = dailyTasks.reduce(0.0) { partial, task in
            let income = task.contractAmount + task.extraPayment - task.cost
            return partial + income
        }

        if debug {
            print("[DailyIncome] Tasks found: \(dailyTasks.count)")
            for t in dailyTasks {
                print("• \(t.taskDescription ?? "Без описания"): \(t.contractAmount)+\(t.extraPayment)-\(t.cost)")
            }
            print("[DailyIncome] Total income for \(startOfDay): \(total)")
        }

        return total
    }
  
    func saveUserDefaults(filters: [TaskStatus], key: String) {
        let rawValues = filters.map { $0.rawValue }
        userDefaults.set(rawValues, forKey: key)
        print("[UserDefaults] Сохранены фильтры:", rawValues)
    }
   
    func loadSavedStatusesFromUserDefaults(key: String) -> [Status]? {
        guard let raw = UserDefaults.standard.array(forKey: key) as? [String] else { return nil }
        let statuses = raw.compactMap { Status(rawValue: $0) }
        return statuses.isEmpty ? nil : statuses
    }
    
    // Преобразование между типами
    func statusToTaskStatus(_ s: Status) -> TaskStatus {
        switch s {
        case .scheduled: return .scheduled
        case .completed: return .completed
        case .canceled:  return .canceled
        }
    }
    
    func taskStatusToStatus(_ t: TaskStatus) -> [Status] {
        print("TaskStatusToStatus called. Task status \(t) converted to array")
        switch t {
        case .scheduled:
            return [.scheduled]
              case .completed:
                  return [.completed]
              case .canceled:
                  return [.canceled]
     
        }
    }
    
    func loadTasks() {
        tasks = store.fetchTasks()
    }

     func applyFiltersAsync() {
        print("[TaskListViewModel] applyFiltersAsync called with searchText:", searchText)
        Task { // без [weak self]
            
            applyCurrentFiltersUsingDB()
        }
    }

    func applyCurrentFiltersUsingDB(debug: Bool = false) {
        print("[TaskListViewModel] applyCurrentFiltersUsingDB called with searchText:", searchText)
        
        var andPreds: [NSPredicate] = []
        
        if let statuses = selectedStatuses, !statuses.isEmpty {
            let raw = statuses.map { $0.rawValue }
            andPreds.append(NSPredicate(format: "statusString IN %@", raw))
        }

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            print("[TaskListViewModel] Searching text:", text)
            let t = text as NSString
            let textPreds: [NSPredicate] = [
                NSPredicate(format: "taskDescription CONTAINS[cd] %@", t),
                NSPredicate(format: "client.firstName CONTAINS[cd] %@", t),
                NSPredicate(format: "client.lastName CONTAINS[cd] %@", t),
                NSPredicate(format: "client.phone CONTAINS[cd] %@", t),
                NSPredicate(format: "ANY client.address.street.name CONTAINS[cd] %@", t)
            ]
            let orText = NSCompoundPredicate(orPredicateWithSubpredicates: textPreds)
            andPreds.append(orText)
        }

        let finalPredicate: NSPredicate? = andPreds.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: andPreds)
        
        if debug { print("[TaskListViewModel] finalPredicate:", finalPredicate?.predicateFormat ?? "<none>") }

        let results: [TaskEntity]
        if let predicate = finalPredicate {
            results = store.fetchTasks(matching: predicate, debug: debug)
        } else {
            results = store.fetchTasks()
        }

        print("[TaskListViewModel] Fetched tasks count:", results.count)
        self.tasks = results
    }
    
    func delete(_ task: TaskEntity) {
        store.deleteTask(task)
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
    
    func loadAllTasksCount(debug: Bool = false) {
        tasksCount = store.totalTasksCount(debug: debug)
        print("loaded all tasks count: \(tasksCount)")
    }
    
    func loadAllCanceledTasksCount(debug: Bool = false) {
        canceledTasksCount = store.totalCanceled(debug: debug)
        print("loaded all canceled tasks count: \(canceledTasksCount)")
    }
    
    // MARK: - Convenience counters
   
    func loadYearCompletedTasks(year: Int,
                        
                        dateKey: String = "scheduledAt",
                        debug: Bool = false) {
        yearCompletedTasksCount = store.countTasks(year: year, month: nil, status: .completed, dateKey: dateKey, debug: debug)
    }

   
    func loadYearCanceledTasks(year: Int,
                       dateKey: String = "scheduledAt",
                       debug: Bool = false) {
        yearCanceledTasksCount = store.countTasks(year: year, month: nil, status: .canceled, dateKey: dateKey, debug: debug)
    }
    
    func loadMonthlyCompletedTasks(year: Int) {
        var temp: [Int] = []
        for month in 1...12 {
            let count = store.countTasks(year: year, month: month, status: .completed)
            temp.append(count)
        }
        monthlyCompletedTasksCounts = temp
    }
    
    func loadMonthlyCanceledTasks(year: Int) {
        var temp: [Int] = []
        for month in 1...12 {
            let count = store.countTasks(year: year, month: month, status: .canceled)
            temp.append(count)
        }
        monthlyCanceledTasksCounts = temp
    }
    
 
}

// MARK: - Task View Models Managments

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
    
    @Published var remoteEditingBlock = false
    @Published var privateHouseBlock = false
    
    @Published var shouldBlockRemote = false
    @Published var shouldBlockPrivate = false
    @Published var didCreateTask: Bool = false
    
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
    
  
    func canSaveTask() -> Bool {
        if isRemote == false {
            !streetName.isBlank && !firstName.isBlank && !phoneDigits.isBlank && !house.isBlank }
            else {
                 !firstName.isBlank && !phoneDigits.isBlank
            }
    }
    
    func updateCreateButtonColor(color: CustomColor) -> CustomColor {
        canSaveTask() ? .highlightBlue
        : .inactiveFiledGray
    }

    func saveTask() {
        let normalizedPhone = phoneDigits.isEmpty ? "" : phoneDigits
        let client = clientStore.createOrFetchClient(
            firstName: firstName,
            lastName: lastName,
            addresses: [],
            phone: normalizedPhone,
            comment: comment.isEmpty ? nil : comment
        )

        let hasAddress = client.addressesArray.count > 0
       
            let street = streetStore.createOrFetchStreet(name: streetName)

            let address = addressStore.createOrFetchAddress(
                house: house,
                apartment: apartment,
                entrance: entrance,
                floor: floor,
                isPrivateHouse: isPrivateHouse,
                street: street,
                client: client,
                isPrimary: !hasAddress ? true : false, // 👈 при создании задания НЕ трогаем primary
                roomType: roomType ?? "кв.",
                entranceType: entranceType ?? "под."
            )

            // link the address with the client
            client.addToAddress(address)
    

        // Создаём задачу
        taskStore.createTask(
            scheduledAt: scheduledAt,
            client: client,
            address: address,        // 👈 новый параметр
            description: description,
            isRemote: isRemote,
            status: status,
            contractAmount: contractAmount,
            cost: cost,
            paymentType: selectedPayment
        )
        didCreateTask = true

        if isRemote {
            print("""
             ✅ Удалённое задание успешно создано:
             📆 Дата: \(scheduledAt)
             👤 Клиент: \(firstName) \(lastName), телефон: \(maskRU(fromDigits: phoneDigits))
             📝 Описание: \(description)
             💬 Комментарий: \(comment)
             🌍 Удалённо: Да
             💵 Сумма по договору: \(contractAmount)
             💸 Издержки: \(cost ?? 0)
             🧾 Статус: \(status.rawValue)
             """)
        } else {
            print("""
             ✅ Задание успешно создано:
             📆 Дата: \(scheduledAt)
             👤 Клиент: \(firstName) \(lastName), телефон: \(maskRU(fromDigits: phoneDigits))
             🏠 Адрес: \(streetName), дом: \(house), \(roomType ?? "") \(apartment), \(entranceType ?? "") \(entrance), этаж \(floor)
             📝 Описание: \(description)
             💬 Комментарий: \(comment)
             🌍 Удалённо: Нет
             💵 Сумма по договору: \(contractAmount)
             💸 Издержки: \(cost ?? 0)
             Тип помещения: \(roomType ?? "")
             Тип входа: \(entranceType ?? "")
             🧾 Статус: \(status.rawValue)
             """)
        }

      
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
    @Published var taskDescription: String = ""
    @Published var paymentType: PaymentType = .none
    @Published var finalAmountText: String = ""
    
    var finalAmount: Double {
        contractAmount + (extraPayment ?? 0) - cost
    }
    

    private let task: TaskEntity
    private let store = TaskStore()

    init(task: TaskEntity) {
        self.task = task
        self.taskDescription = task.taskDescription ?? "No description"
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
    @Published var taskDescription: String = ""
    @Published var paymentType: PaymentType = .none

    private let task: TaskEntity
    private let store = TaskStore()

    init(task: TaskEntity) {
        self.task = task
        self.comment = task.comment ?? ""
    }

    func cancel() {
        store.makeCanceled(task, comment: comment, paymentType: paymentType)
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
  
    @Published var remoteEditingBlock = false
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
    private let task: TaskEntity
    private let store = TaskStore()
    private let streetStore = StreetStore()
    private let addressStore = AddressStore()

    // MARK: - Initialization
    init(task: TaskEntity) {
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
        self.paymentType = PaymentType(rawValue: task.paymentType ?? "")
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

        // Populate address info: сначала пробуем адрес самой задачи, затем fallback на primary-адрес клиента
        if let taskAddress = task.address {
            self.streetName = taskAddress.street?.name ?? ""
            self.house = taskAddress.house ?? ""
            self.apartment = taskAddress.apartment ?? ""
            self.entrance = taskAddress.entrance ?? "?"
            self.floor = taskAddress.floor ?? "?"
            self.isPrivateHouse = taskAddress.isPrivateHouse
            self.roomType = taskAddress.roomType ?? "кв."
            self.entranceType = taskAddress.entranceType ?? "под."
        } else if let primaryAddress = (task.client?.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            self.streetName = primaryAddress.street?.name ?? ""
            self.house = primaryAddress.house ?? ""
            self.apartment = primaryAddress.apartment ?? ""
            self.entrance = primaryAddress.entrance ?? "?"
            self.floor = primaryAddress.floor ?? "?"
            self.isPrivateHouse = primaryAddress.isPrivateHouse
            self.roomType = primaryAddress.roomType ?? "кв."
            self.entranceType = primaryAddress.entranceType ?? "под."
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

    func canSaveTask() -> Bool {
        if isRemote == false {
            !streetName.isBlank && !firstName.isBlank && !phoneDigits.isBlank && !house.isBlank }
            else {
                 !firstName.isBlank && !phoneDigits.isBlank
            }
        
    }
    
    // MARK: - Public methods
    /// Apply changes and save to Core Data
    func update() -> Bool  {
        
        guard canSaveTask(), let client = task.client else {
            if task.client == nil {
                print("❌ Ошибка, у задачи нет клиента")
            } else {
                print("❌ Ошибка, не все обязательные поля заполнены")
            }
            return false
        }
        
        // Обновляем клиента и адрес, как и раньше
        client.firstName = firstName
        client.lastName = lastName
        client.phone =  phoneDigits.isEmpty ? "" : phoneDigits
//        phoneDigits.isEmpty ? "" : "+7" + phoneDigits
        
        // Обновляем адрес, привязанный к задаче (а не обязательно primary-адрес клиента)
        if !isRemote {
            let street = streetStore.createOrFetchStreet(name: streetName)

            if let existingAddress = task.address {
                existingAddress.street = street
                existingAddress.house = house
                existingAddress.apartment = apartment
                existingAddress.entrance = entrance
                existingAddress.floor = floor
                existingAddress.isPrivateHouse = isPrivateHouse
                existingAddress.entranceType = entranceType
                existingAddress.roomType = roomType
            } else {
                // Если у задачи ещё нет адреса, создаём/находим его и привязываем
                let newAddress = addressStore.createOrFetchAddress(
                    house: house,
                    apartment: apartment,
                    entrance: entrance,
                    floor: floor,
                    isPrivateHouse: isPrivateHouse,
                    street: street,
                    client: client,
                    isPrimary: false,
                    roomType: roomType ?? "кв.",
                    entranceType: entranceType ?? "под."
                )
                client.addToAddress(newAddress)
                task.address = newAddress
            }
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
    return true
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

