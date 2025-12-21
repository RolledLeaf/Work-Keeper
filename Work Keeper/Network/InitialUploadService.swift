import Foundation
import CoreData

final class InitialUploadService {
    private let context: NSManagedObjectContext

    private let streetStore = RemoteStreetStore()
    private let clientStore = RemoteClientStore()
    private let addressStore = RemoteAddressStore()
    private let taskStore = RemoteTaskStore()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public

    /// Запусти после логина, когда есть session.user.id
    func run(ownerId: UUID, debug: Bool = true) async throws {
        if debug { print("🚀 InitialUpload started. ownerId:", ownerId) }

        try await uploadStreets(ownerId: ownerId, debug: debug)
        try await uploadClients(ownerId: ownerId, debug: debug)
        try await uploadAddresses(ownerId: ownerId, debug: debug)
        try await uploadTasks(ownerId: ownerId, debug: debug)

        if debug { print("✅ InitialUpload finished") }
    }

    // MARK: - Streets

    private func uploadStreets(ownerId: UUID, debug: Bool) async throws {
        let streets: [Street] = try await fetch(Street.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Streets to upload:", streets.count) }

        for s in streets {
            guard let name = s.name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            let created = try await streetStore.create(name: name, ownerId: ownerId)
            try await context.perform {
                s.remoteId = created.id
                s.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Clients

    private func uploadClients(ownerId: UUID, debug: Bool) async throws {
        let clients: [Client] = try await fetch(Client.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Clients to upload:", clients.count) }

        for c in clients {
            guard
                let first = c.firstName?.trimmingCharacters(in: .whitespacesAndNewlines),
                !first.isEmpty,
                let phone = c.phone?.trimmingCharacters(in: .whitespacesAndNewlines),
                !phone.isEmpty
            else {
                if debug { print("⚠️ Skip client: missing firstName/phone. localId=\(c.id)") }
                continue
            }

            let created = try await clientStore.create(
                   firstName: first,
                   lastName: c.lastName,
                   phone: phone,
                   comment: c.comment,
                   ownerId: ownerId
               )

            try await context.perform {
                c.remoteId = created.id
                c.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Addresses

    private func uploadAddresses(ownerId: UUID, debug: Bool) async throws {
        let addresses: [Address] = try await fetch(Address.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Addresses to upload:", addresses.count) }

        for a in addresses {
            // 1) client remoteId
            guard let client = a.client, let clientId = client.remoteId else {
                if debug { print("⚠️ Skip address: missing client.remoteId") }
                continue
            }
            // 2) street remoteId
            guard let street = a.street, let streetId = street.remoteId else {
                if debug { print("⚠️ Skip address: missing street.remoteId") }
                continue
            }
            guard let house = a.house?.trimmingCharacters(in: .whitespacesAndNewlines), !house.isEmpty else {
                if debug { print("⚠️ Skip address: missing house. localId=\(a.objectID)") }
                continue
            }

            let payload = AddressInsertDTO(
                owner_id: ownerId,
                client_id: clientId,
                street_id: streetId,
                house: house,
                apartment: a.apartment,
                entrance: a.entrance,
                entrance_type: a.entranceType,
                room_type: a.roomType,
                floor: a.floor,
                is_primary: a.isPrimary,
                is_private_house: a.isPrivateHouse
            )

            let created = try await addressStore.create(payload)

            try await context.perform {
                a.remoteId = created.id
                a.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Tasks

    private func uploadTasks(ownerId: UUID, debug: Bool) async throws {
        let tasks: [TaskEntity] = try await fetch(TaskEntity.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Tasks to upload:", tasks.count) }

        for t in tasks {
            // 1) client remoteId required always
            guard let client = t.client, let clientId = client.remoteId else {
                if debug { print("⚠️ Skip task: missing client.remoteId") }
                continue
            }

            guard let scheduledAt = t.scheduledAt else {
                if debug { print("⚠️ Skip task: missing scheduledAt. localId=\(t.id)") }
                continue
            }
            guard let status = t.statusString?.trimmingCharacters(in: .whitespacesAndNewlines), !status.isEmpty else {
                if debug { print("⚠️ Skip task: missing statusString. localId=\(t.id)") }
                continue
            }

            let allowedStatuses: Set<String> = ["scheduled", "completed", "canceled"]
            guard allowedStatuses.contains(status) else {
                if debug { print("⚠️ Skip task: unknown status '\(status)'. localId=\(t.id)") }
                continue
            }

            let isRemote = t.isRemote
            let addressId: UUID?

            if isRemote {
                addressId = nil
            } else {
                // non-remote requires address remoteId
                guard let addr = t.address, let rid = addr.remoteId else {
                    if debug { print("⚠️ Skip task: non-remote but missing address.remoteId") }
                    continue
                }
                addressId = rid
            }

            let payload = TaskInsertDTO(
                owner_id: ownerId,
                scheduled_at: scheduledAt,
                task_description: t.taskDescription,
                payment_type: t.paymentType,
                comment: t.comment,
                is_remote: isRemote,
                statusString: status,
                contract_amount: t.contractAmount,
                cost: t.cost,
                extra_payment: t.extraPayment,
                client_id: clientId,
                address_id: addressId
            )

            let created = try await taskStore.create(payload)

            try await context.perform {
                t.remoteId = created.id
                t.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - CoreData helpers

    private func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate) async throws -> [T] {
        try await context.perform {
            let req = NSFetchRequest<T>(entityName: String(describing: type))
            req.predicate = predicate
            return try self.context.fetch(req)
        }
    }

    private func saveIfNeeded() async throws {
        try await context.perform {
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
}
