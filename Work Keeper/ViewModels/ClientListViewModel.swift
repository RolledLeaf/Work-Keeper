

import Foundation
import Combine

final class ClientsListViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var selectedClient: Client?

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
    @Published var fistName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var addresses: [Address] = []
    @Published var comment: String = ""
    
    private let store = ClientStore()
    
    func createClient() {
        store.createClient(
            firstName: fistName,
            lastName: lastName,
            addresses: addresses,
            phone: phone,
            comment: comment
        )
    }
}
