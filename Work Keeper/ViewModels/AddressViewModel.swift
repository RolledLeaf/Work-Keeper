import Foundation
import Combine
import CoreData

final class AddressListViewModel: ObservableObject {
    @Published var addresses: [Address] = []
    @Published var client: Client?

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

final class ClientAddressesViewModel: ObservableObject {

    /// Делает адрес основным у клиента, сохраняет и обновляет client для всех ObservedObject.
    func setPrimary(_ address: Address, for client: Client, in context: NSManagedObjectContext) {
        if let all = client.address as? Set<Address> {
            for addr in all {
                addr.isPrimary = (addr == address)
            }
        } else {
            address.isPrimary = true
        }

        do {
            try context.save()
            context.refresh(client, mergeChanges: true)
        } catch {
            print("[ClientAddressesViewModel] Failed to save primary address:", error)
        }
    }

    /// Мягкое удаление + выставление флагов синхронизации.
    /// Если удаляем основной адрес — выбираем новый основной из оставшихся.
    func softDelete(_ address: Address, for client: Client, in context: NSManagedObjectContext) {
        address.deletedAt = Date()
        address.needsSync = true
        address.updatedAt = Date()

        if address.isPrimary {
            let remaining = client.addressesArray
                .filter { $0.objectID != address.objectID }
                .filter { $0.deletedAt == nil }

            if let newPrimary = remaining.first {
                for addr in remaining {
                    addr.isPrimary = (addr.objectID == newPrimary.objectID)
                }
                newPrimary.isPrimary = true
            }
            address.isPrimary = false
        }

        do {
            try context.save()
            context.refresh(client, mergeChanges: true)
        } catch {
            print("[ClientAddressesViewModel] Failed to soft-delete address:", error)
        }
    }
}
