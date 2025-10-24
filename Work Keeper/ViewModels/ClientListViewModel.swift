
import Foundation
import Combine

enum SortOption: String, CaseIterable, Identifiable {
    case nameAZ = "По именам А-Я"
    case nameZA = "По именам Я-А"
//    case addressAZ = "По адресам А-Я"
//    case addressZA = "По адресам Я-А"
    case moreCompleted = "Больше выполненных заданий"
    case lessCompleted = "Меньше выполненных заданий"
    
    var id: String { rawValue }
    
    var sortKey: String? {
        switch self {
        case .nameAZ, .nameZA: return "firstName"
//        case .addressAZ, .addressZA: return "address.street.name"
        case .moreCompleted, .lessCompleted: return nil
        }
    }
    var ascendingForSortKey: Bool {
        switch self {
        case .nameAZ/*, .addressAZ*/: return true
        case .nameZA/*, .addressZA*/: return false
        case .moreCompleted: return false
        case .lessCompleted: return true
        }
    }
}

// Временно исключить сортировку по адресам, пока нет сетевого эндпоинта, так как сортировать to-many объекты из базы данных невоможно

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
    @Published var clients: [Client] = []
    @Published var selectedClient: Client?
    @Published var client: Client?
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var searchText: String = ""
    @Published var total: Int = 0
    @Published var sortSelection: SortOption = .lessCompleted
    
    private var cancellables = Set<AnyCancellable>()

    private let store = ClientStore()
    
    init() {
 
        $searchText
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.applySearchUsingDB()
            }
            .store(in: &cancellables)
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
    }
    
    func loadSortedByCount(ascending: Bool) {
        clients = store.fetchClientsSortedByCompletedCountDB(descending: ascending, limit: nil, debug: true)
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
            case .moreCompleted:
                loadSortedByCount(ascending: true)
                print("UserDefaults loaded: Clients sorted by moreCompleted")
            case .lessCompleted:
                loadSortedByCount(ascending: false)
                print("UserDefaults loaded: Clients sorted by lessCompleted")
            }
        }
    
    }
    
    func loadUserDefaultsAndApplySorting(sortingOption: SortOption) {
       if let savedSorting = userDefaults.string(forKey: UserDefaultsKeys.clientsSorting.rawValue),
          let sortingOption = SortOption(rawValue: savedSorting) {
   
           switch sortingOption {
           case .nameAZ:
               clients = store.fetchClients(sortedBy: "name", ascending: true)
           case .nameZA:
               clients = store.fetchClients(sortedBy: "name", ascending: false)
           case .moreCompleted:
               loadSortedByCount( ascending: true)
           case .lessCompleted:
               loadSortedByCount( ascending: false)
           }
       }
    }
    
 
    func applySort(option: SortOption) {
        if let key = option.sortKey {
            loadSorted(sortingString: key, ascending: option.ascendingForSortKey)
            saveUserDefaults(option: option, key: UserDefaultsKeys.clientsSorting.rawValue)
            
        } else {
            switch option {
            case .moreCompleted: loadSortedByCount( ascending: true)
                saveUserDefaults(option: option, key: UserDefaultsKeys.clientsSorting.rawValue)
            case .lessCompleted: loadSortedByCount( ascending: false)
                saveUserDefaults(option: option, key: UserDefaultsKeys.clientsSorting.rawValue)
            default: break
            }
        }
    }
    
    func pickClient(_ client: Client) {
        selectedClient = client
    }
    
    func loadClients() {
        clients = store.fetchClients()
    }
    
    func delete(_ client: Client) {
        store.deleteClient(client)
        loadClients()
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
    
    private let store = ClientStore()
    private let streetStore = StreetStore()
    private let addressStore = AddressStore()
    
    func canCreateClient() -> Bool {
        !firstName.isEmpty && !phoneDigits.isEmpty 
    }
    
    func createClient() {
        // 1) Улица
        let street = streetStore.createOrFetchStreet(name: streetName.trimmingCharacters(in: .whitespacesAndNewlines))
        
        // 2) Клиент (пока без адресов)
        let client = store.createClient(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            addresses: [],
            phone: phoneDigits.isEmpty ? "" : "+7" + phoneDigits
        )
        
        // 3) Адрес, привязанный к клиенту
        let address = addressStore.createOrFetchAddress(
            house: building.trimmingCharacters(in: .whitespacesAndNewlines),
            apartment: apartment.trimmingCharacters(in: .whitespacesAndNewlines),
            entrance: entrance.trimmingCharacters(in: .whitespacesAndNewlines),
            floor: floor,
            isPrivateHouse: isPrivateHouse,
            street: street,
            client: client,
            isPrimary: true,
            roomType: roomType,
            entranceType: entranceType
        )
        
        // 4) Обновляем клиента, чтобы адрес точно оказался в его наборе адресов и сохранился комментарий
        store.updateClient(
            client,
            firstName: client.firstName ?? "",
            lastName: client.lastName,
            addresses: [address],
            phone: client.phone ?? ""
        )
    }
}
