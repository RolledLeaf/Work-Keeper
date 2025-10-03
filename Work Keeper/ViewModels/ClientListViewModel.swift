

import Foundation
import Combine


final class ClientsStatViewModel: ObservableObject {
    private let store = ClientStore()
    
    @Published var allClientsCount: Int = 0                  // всего клиентов в базе
       @Published var yearActiveClientsCount: Int = 0           // уникальные клиенты с задачами за выбранный год
       @Published var monthActiveClientsCount: Int = 0          // уникальные клиенты с задачами за выбранный месяц
       @Published var monthlyActiveCounts: [Int] = Array(repeating: 0, count: 12) // по месяцам выбранного года

    
    func loadAllClientsCount(debug: Bool = false) {
        allClientsCount = store.totalClientsCount(debug: debug)
        print("loaded all clients count: \(allClientsCount)")
    }
    
    func loadYearActiveClients(year: Int,
                                  onlyCompleted: Bool = true,
                                  dateKey: String = "scheduledAt",
                                  debug: Bool = false) {
           yearActiveClientsCount = store.distinctClientsCount(year: year,
                                                               month: nil,
                                                               onlyCompleted: onlyCompleted,
                                                               dateKey: dateKey,
                                                               debug: debug)
       }
    
    func loadMonthActiveClients(year: Int,
                                month: Int,
                                onlyCompleted: Bool = true,
                                dateKey: String = "scheduledAt",
                                debug: Bool = false) {
        monthActiveClientsCount = store.distinctClientsCount(year: year,
                                                             month: month,
                                                             onlyCompleted: onlyCompleted,
                                                             dateKey: dateKey,
                                                             debug: debug)
    }
    
    func loadMonthlyActive(year: Int,
                           onlyCompleted: Bool = true,
                           dateKey: String = "scheduledAt",
                           debug: Bool = false) {
        monthlyActiveCounts = (1...12).map { m in
            store.distinctClientsCount(year: year,
                                       month: m,
                                       onlyCompleted: onlyCompleted,
                                       dateKey: dateKey,
                                       debug: debug)
        }
    }
    
}


final class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var selectedClient: Client?
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    
    @Published var client: Client?
    
    @Published var total: Int = 0
  

    private let store = ClientStore()

    init() {
        loadClients()
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
