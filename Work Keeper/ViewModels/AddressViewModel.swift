import Foundation
import Combine

final class AddressListViewModel: ObservableObject {
    @Published var addresses: [Address] = []

    private let store = AddressStore()

    init() {
        loadAddresses()
    }

    func loadAddresses() {
        addresses = store.fetchAddresses()
    }

    func delete(_ address: Address) {
        store.deleteAddress(address)
        loadAddresses()
    }
}
