
import Foundation
import Combine
import CoreData

enum SortOption: String, CaseIterable, Identifiable {
    case nameAZ = "По именам А-Я"
    case nameZA = "По именам Я-А"

    
    var id: String { rawValue }
    
    var sortKey: String? {
        switch self {
        case .nameAZ, .nameZA: return "firstName"

        }
    }
    var ascendingForSortKey: Bool {
        switch self {
        case .nameAZ: return true
        case .nameZA: return false
        }
    }
}


final class ClientsStatViewModel: ObservableObject {
    private let store = ClientStore()
    
    @Published var allClientsCount: Int = 0                  // всего клиентов в базе
    //       @Published var yearActiveClientsCount: Int = 0           // уникальные клиенты с задачами за выбранный год
    
    @Published var monthlyActiveCounts: [Int] = Array(repeating: 0, count: 12) // по месяцам выбранного года
    
    
    func loadAllClientsCount(debug: Bool = false) {
        allClientsCount = store.totalClientsCount(debug: debug)
        print("loaded all clients count: \(allClientsCount)")
    }
    
    func loadMonthlyActive(year: Int,
                           onlyCompleted: Bool = false,
                           dateKey: String = "scheduledAt",
                           debug: Bool = false) {
        monthlyActiveCounts =
        store.newClientsByMonth(year: year, onlyCompleted: true)
    }
}




final class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = [] {
        didSet {
            rebuildClientsGroupedByFirstLetter()
        }
    }
    @Published var removedClients: [Client] = []
    
    
    @Published var clientsGroupedByFirstLetter: [(letter: String, clients: [Client])] = []
    @Published var selectedClient: Client?
    @Published var pickedAddress: Address?
    @Published var client: Client?
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var searchText: String = ""
    @Published var total: Int = 0
    @Published var sortSelection: SortOption = .nameAZ
    @Published var didPickNewAddress = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private let store = ClientStore()
    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    private let context: NSManagedObjectContext
    private let tombstones: PendingDeleteStore
    
    
    var removedClientsSortedByDeletedAt: [Client] {
        removedClients.sorted {
            ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast)
        }
    }

   init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        self.tombstones = PendingDeleteStore(context: context)

        rebuildClientsGroupedByFirstLetter()

        $searchText
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.applySearchUsingDB()
            }
            .store(in: &cancellables)
    }
    
  
    
    private func rebuildClientsGroupedByFirstLetter() {
        let grouped = Dictionary(grouping: clients) { client -> String in
            let name = (client.firstName ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let first = name.first else { return "#" }
            return String(first).uppercased()
        }
        
        let ascending = sortSelection.ascendingForSortKey
        
        // Секции: А→Я или Я→А. "#" всегда в конце
        let sortedLetters = grouped.keys.sorted { a, b in
            if a == "#" { return false }
            if b == "#" { return true }
            
            let cmp = a.localizedStandardCompare(b)
            return ascending ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
        }
        
        clientsGroupedByFirstLetter = sortedLetters.map { letter in
            let items = (grouped[letter] ?? []).sorted { a, b in
                let aFirst = (a.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let bFirst = (b.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let firstCmp = aFirst.localizedStandardCompare(bFirst)
                if firstCmp != .orderedSame {
                    return ascending ? (firstCmp == .orderedAscending) : (firstCmp == .orderedDescending)
                }
                
                let aLast = (a.lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let bLast = (b.lastName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let lastCmp = aLast.localizedStandardCompare(bLast)
                if lastCmp != .orderedSame {
                    return ascending ? (lastCmp == .orderedAscending) : (lastCmp == .orderedDescending)
                }
                
                // запасной стабильный ключ
                return (a.phone ?? "") < (b.phone ?? "")
            }
            
            return (letter: letter, clients: items)
        }
    }
    
    func pickClientWithNewAddress(_ client: Client) {
        selectedClient = client
        pickedAddress = nil
        didPickNewAddress = true
    }
    
    func applySearchUsingDB(debug: Bool = false) {
        print(" Applying search: \(searchText)")
        let q = searchText
        guard !q.isBlank else {
            loadUserDefaultsAndSort()
            return
        }
        
        let t = q as NSString
        // Build a predicate that matches firstName/lastName/phone OR any related address.street.name
        let namePred = NSPredicate(format: "firstName CONTAINS[cd] %@", t)
        let lastPred = NSPredicate(format: "lastName CONTAINS[cd] %@", t)
        let phonePred = NSPredicate(format: "phone CONTAINS[cd] %@", t)
        // Use SUBQUERY to avoid unsupported SQL generation for multi-hop ANY predicates
        let addressSubquery = NSPredicate(format: "SUBQUERY(address, $a, $a.street.name CONTAINS[cd] %@).@count > 0", t)
        let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePred, lastPred, phonePred, addressSubquery])
        
        if debug { print("[ClientsListViewModel] applySearchUsingDB predicate:", orPredicate.predicateFormat) }
        clients = store.fetchClients(matching: orPredicate)
    }
    
    
    func loadSorted(sortingString: String, ascending: Bool) {
        clients = store.fetchClients(sortedBy: sortingString, ascending: ascending )
        print("loading clients sorted by: \(sortingString), ascending: \(ascending)")
    }
    
    
    func saveUserDefaults(option: SortOption, key: String) {
        userDefaults.set(option.rawValue, forKey: key)
        print("Clients \(option) sorting is saved")
    }
    
    func loadUserDefaultsAndSort() {
        if let savedSorting = userDefaults.string(forKey: UserDefaultsKeys.clientsSorting.rawValue),
           let sortType = SortOption(rawValue: savedSorting) {
            
            sortSelection = sortType
            
            switch sortSelection {
            case .nameAZ:
                loadClients()
                print("UserDefaults loaded: Clients sorted by NameAZ")
            case .nameZA:
                loadSorted(sortingString: sortType.sortKey ?? "", ascending: false)
                print("UserDefaults loaded: Clients sorted by NameZA")
                
            }
        } else {
            loadClients()
        }
    }
    
    
    func applySort(option: SortOption) {
        if let key = option.sortKey {
            loadSorted(sortingString: key, ascending: option.ascendingForSortKey)
            saveUserDefaults(option: option, key: UserDefaultsKeys.clientsSorting.rawValue)

        }
    }
   
    func pickClient(_ client: Client) {
        selectedClient = client
        // если адрес не выбирали явно, сбрасываем предыдущий выбор
        pickedAddress = nil
    }
    
    func pickClient(_ client: Client, address: Address) {
        selectedClient = client
        pickedAddress = address
    }
    
    func loadClients() {
        clients = store.fetchClients()
    }
    
  
    func loadRemovedClients() {
        removedClients = store.fetchRemovedClients()
    }
        
        func addAddress(
            to client: Client,
            streetName: String,
            house: String,
            apartment: String,
            entrance: String,
            floor: String,
            isPrivateHouse: Bool,
            roomType: String,
            entranceType: String,
            makePrimary: Bool,
            debug: Bool = false
        ) {
            let trimmedStreet = streetName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedHouse = house.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedApartment = apartment.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEntrance = entrance.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedFloor = floor.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedStreet.isEmpty, !trimmedHouse.isEmpty else {
                if debug { print("❌ addAddress: street/house are required") }
                return
            }

            guard let street = streetStore.createOrFetchStreet(name: trimmedStreet) else {
                if debug { print("❌ addAddress: failed to createOrFetchStreet") }
                return
            }

            let existing = (client.address as? Set<Address>) ?? []
            let hasNoAddresses = existing.isEmpty
            let shouldBePrimary = makePrimary || hasNoAddresses

            // If user wants it primary (or it is the first address) — drop primary flag from others.
            if shouldBePrimary {
                existing.forEach { $0.isPrimary = false }
            }

            let newAddress = addressStore.createOrFetchAddress(
                house: trimmedHouse,
                apartment: trimmedApartment,
                entrance: trimmedEntrance,
                floor: trimmedFloor,
                isPrivateHouse: isPrivateHouse,
                street: street,
                client: client,
                isPrimary: shouldBePrimary,
                roomType: roomType,
                entranceType: entranceType
            )

            // Keep all addresses + new one
            var updatedAddresses = Array(existing)
            updatedAddresses.append(newAddress)

            store.updateClient(
                client,
                firstName: client.firstName ?? "",
                lastName: client.lastName,
                comment: client.comment,
                addresses: updatedAddresses,
                phone: client.phone ?? ""
            )

            // refresh list
            loadClients()
        }

    func restore(_ client: Client) {
        store.restoreClient(client)
        loadRemovedClients()
    }
    
    func softDelete(_ client: Client) {
        store.deleteClient(client)
        loadClients()
    }

    func delete(_ client: Client) {
        if let rid = client.remoteId {
            tombstones.enqueue(.clients, remoteId: rid)
        }

        store.purgeClient(client)
        loadRemovedClients()
    }

    func purgeAllRemovedClients() {
        // Enqueue tombstones for every removed client that exists on the server.
        removedClients.forEach { c in
            if let rid = c.remoteId {
                tombstones.enqueue(.clients, remoteId: rid)
            }
        }
        // Permanent local purge
        let toDelete = removedClients
        toDelete.forEach { store.purgeClient($0) }
        loadRemovedClients()
    }
}

final class CreateClientViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var phoneDigits: String = ""
    @Published var addresses: [Address] = []
    @Published var apartment: String = ""
    @Published var comment: String = ""
    @Published var entrance = ""
    @Published var floor = ""
    @Published var street = ""
    @Published var building = ""
    @Published var streetName = ""
    @Published var countryCode: String = ""
    @Published var isPrivateHouse: Bool = false
    
    
    @Published var roomType = "кв"
    @Published var entranceType = "под"
    
    let roomTypes = ["кв", "оф", "каб"]
    let entranceTypes = ["под", "вход"]
    
    private let store = ClientStore()
    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    
    /// Проверяет, что заполнены обязательные поля: имя и номер телефона
    func hasRequiredNameAndPhone() -> Bool {
        let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneDigits.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isBlank && !phone.isBlank
    }

    /// Проверяет, что номер телефона не занят другим клиентом
    func hasUniquePhone() -> Bool {
        let normalizedPhone = phoneDigits.trimmingCharacters(in: .whitespacesAndNewlines)
        // Если номер пустой, считаем, что проверка уникальности не пройдена
        guard !normalizedPhone.isBlank else { return false }

        let existsAnother = store.hasClient(withPhone: normalizedPhone, excluding: nil)
        return !existsAnother
    }

    /// Общая проверка перед созданием клиента
    func canCreateClient() -> Bool {
        hasRequiredNameAndPhone() && hasUniquePhone()
    }
    
    func createClient() {
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trimmedStreetName = streetName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBuilding = building.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApartment = apartment.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEntrance = entrance.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFloor = floor.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) Клиент (может быть создан без адреса — например, если он всегда на удалёнке)
        let client = store.createClient(
            firstName: trimmedFirstName,
            lastName: trimmedLastName,
            addresses: [],
            phone: phoneDigits.isBlank ? "" : phoneDigits,
            comment: comment
        )

        // 2) Если улица не указана — адрес не создаём
        guard !trimmedStreetName.isBlank else {
            // Сохраняем/обновляем базовые поля клиента (включая comment через createClient)
            store.updateClient(
                client,
                firstName: client.firstName ?? "",
                lastName: client.lastName,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                addresses: [],
                phone: client.phone ?? ""
            )
            return
        }

        // 3) Улица + адрес
        guard let street = streetStore.createOrFetchStreet(name: trimmedStreetName) else {
            print("❌ createClient: invalid streetName")
            store.updateClient(
                client,
                firstName: client.firstName ?? "",
                lastName: client.lastName,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                addresses: [],
                phone: client.phone ?? ""
            )
            return
        }

        let address = addressStore.createOrFetchAddress(
            house: trimmedBuilding,
            apartment: trimmedApartment,
            entrance: trimmedEntrance,
            floor: trimmedFloor,
            isPrivateHouse: isPrivateHouse,
            street: street,
            client: client,
            isPrimary: true,
            roomType: roomType,
            entranceType: entranceType
        )

        // 4) Обновляем клиента, чтобы адрес оказался в его наборе адресов
        store.updateClient(
            client,
            firstName: client.firstName ?? "",
            lastName: client.lastName,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            addresses: [address],
            phone: client.phone ?? ""
        )
    }
}

final class EditClientViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var streetName: String
    @Published var house: String
    @Published var apartment: String
    @Published var entrance: String
    @Published var floor: String
    @Published var isPrivateHouse: Bool
    @Published var roomType: String
    @Published var entranceType: String
    @Published var phoneNumber: String
    @Published var phoneDigits: String = ""
    @Published var comment: String
    
    let roomTypes = ["кв", "оф", "каб"]
    let entranceTypes = ["под", "вход"]
    
    private let client: Client
    private let store = ClientStore()
    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    
    init(client: Client) {
        let rawPhone = client.phone ?? ""
       
        self.phoneDigits = rawPhone
     
        self.client = client
        self.firstName = client.firstName ?? ""
        self.lastName = client.lastName ?? ""
        
        //Populate client info
        self.firstName = client.firstName ?? ""
        self.lastName = client.lastName ?? ""
        self.phoneNumber = client.phone ?? ""
        self.comment = client.comment ?? ""
        
        
        if let address = (client.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            self.streetName = address.street?.name ?? ""
            self.house = address.house ?? ""
            self.apartment = address.apartment ?? ""
            self.entrance = address.entrance ?? ""
            self.floor = address.floor ?? ""
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
            self.phoneNumber = ""
        }
    }
    
    
    
    /// Проверяет, что заполнены обязательные поля: имя и номер телефона
    func hasRequiredNameAndPhone() -> Bool {
        let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = phoneDigits.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isBlank && !phone.isBlank
    }

    /// Проверяет, что номер телефона не занят другим клиентом
    func hasUniquePhone() -> Bool {
        let normalizedPhone = phoneDigits.trimmingCharacters(in: .whitespacesAndNewlines)
        // Если номер пустой, считаем, что проверка уникальности здесь не проходит
        guard !normalizedPhone.isEmpty else { return false }

        let existsAnother = store.hasClient(withPhone: normalizedPhone, excluding: client)
        return !existsAnother
    }

    /// Общая проверка перед сохранением клиента
    func canUpdateClient() -> Bool {
        hasRequiredNameAndPhone() && hasUniquePhone()
    }
    
    func update() {
        // normalize phone
        let phoneValue = phoneDigits.isEmpty ? "" : phoneDigits

        // Update client basic fields
        client.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        client.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        client.phone = phoneValue
        client.comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)

        // Prepare an array of addresses to persist.
        // Address is optional: if streetName is empty, we do not touch/create addresses.
        var resultingAddresses: [Address] = []

        let trimmedStreetName = streetName.trimmingCharacters(in: .whitespacesAndNewlines)

        // If no street provided, keep existing addresses as-is (or none) and only update basic client fields.
        guard !trimmedStreetName.isBlank else {
            resultingAddresses = (client.address as? Set<Address>)?.sorted(by: { ($0.street?.name ?? "") < ($1.street?.name ?? "") }) ?? []
            store.updateClient(
                client,
                firstName: client.firstName ?? "",
                lastName: client.lastName,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                addresses: resultingAddresses,
                phone: client.phone ?? ""
            )
            return
        }

        guard let streetObj = streetStore.createOrFetchStreet(name: trimmedStreetName) else {
            print("❌ updateClient: invalid streetName")
            resultingAddresses = (client.address as? Set<Address>)?.sorted(by: { ($0.street?.name ?? "") < ($1.street?.name ?? "") }) ?? []
            store.updateClient(
                client,
                firstName: client.firstName ?? "",
                lastName: client.lastName,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
                addresses: resultingAddresses,
                phone: client.phone ?? ""
            )
            return
        }

        if let existingPrimary = (client.address as? Set<Address>)?.first(where: { $0.isPrimary }) {
            existingPrimary.street = streetObj
            existingPrimary.house = house.trimmingCharacters(in: .whitespacesAndNewlines)
            existingPrimary.apartment = apartment.trimmingCharacters(in: .whitespacesAndNewlines)
            existingPrimary.entrance = entrance.trimmingCharacters(in: .whitespacesAndNewlines)
            existingPrimary.floor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
            existingPrimary.isPrivateHouse = isPrivateHouse
            existingPrimary.entranceType = entranceType
            existingPrimary.roomType = roomType

            resultingAddresses = [existingPrimary]
        } else {
            let newAddress = addressStore.createOrFetchAddress(
                house: buildingSafe(house),
                apartment: apartment.trimmingCharacters(in: .whitespacesAndNewlines),
                entrance: entrance.trimmingCharacters(in: .whitespacesAndNewlines),
                floor: floor.trimmingCharacters(in: .whitespacesAndNewlines),
                isPrivateHouse: isPrivateHouse,
                street: streetObj,
                client: client,
                isPrimary: true,
                roomType: roomType,
                entranceType: entranceType
            )
            resultingAddresses = [newAddress]
        }

        // Persist changes using store.updateClient which will save context
        store.updateClient(
            client,
            firstName: client.firstName ?? "",
            lastName: client.lastName,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            addresses: resultingAddresses,
            phone: client.phone ?? ""
        )
        
        print("Client has been updated with: \(client.firstName ?? "") \(client.lastName ?? ""), \(comment) ")
    }

    // helper to avoid passing optional empty strings
    private func buildingSafe(_ s: String) -> String {
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
