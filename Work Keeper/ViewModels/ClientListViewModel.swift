
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
    @Published var total: Int = 0

    private let store = ClientStore()
    
    init() {
        loadClients()
    }
    
    
    func loadSorted(sortingString: String, ascending: Bool) {
        clients = store.fetchClients(sortedBy: sortingString, ascending: ascending )
    } //метод для сортировки по именам
    
    func loadSortedByCount(ascending: Bool) {
        clients = store.fetchClientsSortedByCompletedCountDB(descending: ascending, limit: nil, debug: true)
    } //метод для сортировки по количеству выполненных заданий
    
    func applySort(option: SortOption) {
        if let key = option.sortKey {
            loadSorted(sortingString: key, ascending: option.ascendingForSortKey)
        } else {
            switch option {
            case .moreCompleted: loadSortedByCount( ascending: true)
            case .lessCompleted: loadSortedByCount( ascending: false)
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
    
    @Published var phoneDigits: String = ""  // храним только 10 цифр РФ
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
