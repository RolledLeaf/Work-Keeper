import Foundation
import CoreData

final class PullSyncService {
    private let context: NSManagedObjectContext

    private let streetStore = RemoteStreetStore()
    private let clientStore = RemoteClientStore()
    private let addressStore = RemoteAddressStore()
    private let taskStore = RemoteTaskStore()

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public

    /// Pull all remote data into CoreData (upsert + soft-delete)
    func run(ownerId: UUID, debug: Bool = true) async throws {
        if debug { print("⬇️ PullSync started. ownerId:", ownerId) }

        // порядок важен из-за связей
        let streets = try await fetchAllStreets(ownerId: ownerId)
        try await upsertStreets(streets, debug: debug)

        let clients = try await fetchAllClients(ownerId: ownerId)
        try await upsertClients(clients, debug: debug)

        let addresses = try await fetchAllAddresses(ownerId: ownerId)
        try await upsertAddresses(addresses, debug: debug)

        let tasks = try await fetchAllTasks(ownerId: ownerId)
        try await upsertTasks(tasks, debug: debug)

        if debug { print("✅ PullSync finished") }
    }

    // MARK: - Remote fetches

    private func fetchAllStreets(ownerId: UUID) async throws -> [StreetDTO] {
        // если в твоём RemoteStreetStore уже есть fetchAll — используй его
        try await streetStore.fetchAll(ownerId: ownerId, includeDeleted: true)
    }

    private func fetchAllClients(ownerId: UUID) async throws -> [ClientDTO] {
        try await clientStore.fetchAll(ownerId: ownerId, includeDeleted: true)
    }

    private func fetchAllAddresses(ownerId: UUID) async throws -> [AddressDTO] {
        try await addressStore.fetchAll(ownerId: ownerId, includeDeleted: true)
    }

    private func fetchAllTasks(ownerId: UUID) async throws -> [TaskDTO] {
        try await taskStore.fetchAll(ownerId: ownerId, includeDeleted: true)
    }
    
    private func purgeInvalidStreets(debug: Bool = false) throws {
        // Street.name is required in CoreData. Purge any invalid objects left in the context.
        let req: NSFetchRequest<Street> = Street.fetchRequest()
        req.predicate = NSPredicate(format: "name == nil OR name == ''")
        let invalid = try context.fetch(req)
        if debug, !invalid.isEmpty {
            print("🧹 Purging invalid Streets:", invalid.count)
        }
        invalid.forEach { context.delete($0) }
    }
    
    private func purgeInvalidAddresses(debug: Bool = false) throws {
        // Address.street is required (and usually client/house too). Purge any invalid objects left in the context.
        let req: NSFetchRequest<Address> = Address.fetchRequest()
        req.predicate = NSPredicate(format: "street == nil OR client == nil OR house == nil OR house == ''")
        let invalid = try context.fetch(req)
        if debug, !invalid.isEmpty {
            print("🧹 Purging invalid Addresses:", invalid.count)
        }
        invalid.forEach { context.delete($0) }
    }
    
    private func purgeInvalidClients(debug: Bool = false) throws {
        // Client.firstName and Client.phone are required in UX (and often in CoreData). Purge invalid objects.
        let req: NSFetchRequest<Client> = Client.fetchRequest()
        req.predicate = NSPredicate(format: "firstName == nil OR firstName == '' OR phone == nil OR phone == ''")
        let invalid = try context.fetch(req)
        if debug, !invalid.isEmpty {
            print("🧹 Purging invalid Clients:", invalid.count)
        }
        invalid.forEach { context.delete($0) }
    }

    private func purgeInvalidTasks(debug: Bool = false) throws {
        // TaskEntity requires a client and scheduledAt; if non-remote, address is required.
        let req: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        req.predicate = NSPredicate(format: "client == nil OR scheduledAt == nil OR (isRemote == NO AND address == nil)")
        let invalid = try context.fetch(req)
        if debug, !invalid.isEmpty {
            print("🧹 Purging invalid Tasks:", invalid.count)
        }
        invalid.forEach { context.delete($0) }
    }

    // MARK: - Upsert helpers (CoreData)

    private func upsertStreets(_ remote: [StreetDTO], debug: Bool) async throws {
        if debug { print("⬇️ Streets remote count:", remote.count) }

        try await context.perform { [self] in
            for r in remote {
                
                // Defensive: CoreData Street.name is required.
                let trimmedName = r.name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedName.isEmpty else {
                    if debug {
                        print("⚠️ Skip remote Street with empty name. remoteId=\(r.id) deleted_at=\(String(describing: r.deleted_at))")
                    }
                    continue
                }

                
                let local = self.findOrCreateStreet(remoteId: r.id)

                if !self.shouldApplyRemoteUpdate(remoteUpdatedAt: r.updated_at, localUpdatedAt: local.updatedAt) {
                    continue
                }

                local.name = trimmedName
                local.remoteId = r.id
                local.deletedAt = r.deleted_at
                local.updatedAt = r.updated_at ?? Date()
            }

            try self.purgeInvalidStreets(debug: debug)
            try self.purgeInvalidAddresses(debug: debug)

            try self.context.saveIfNeeded()
        }
    }

    private func upsertClients(_ remote: [ClientDTO], debug: Bool) async throws {
        if debug { print("⬇️ Clients remote count:", remote.count) }
        try await context.perform { [self] in
            for r in remote {
                let first = r.first_name.trimmingCharacters(in: .whitespacesAndNewlines)
                let phone = r.phone.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !first.isEmpty, !phone.isEmpty else {
                    if debug {
                        print("⚠️ Skip remote Client with empty firstName/phone. remoteId=\(r.id)")
                    }
                    continue
                }

                let local = self.findOrCreateClient(remoteId: r.id)

                if !self.shouldApplyRemoteUpdate(remoteUpdatedAt: r.updated_at, localUpdatedAt: local.updatedAt) {
                    continue
                }

                local.firstName = first
                local.lastName = r.last_name?.trimmingCharacters(in: .whitespacesAndNewlines)
                local.phone = phone
                local.comment = r.comment

                local.remoteId = r.id
                local.deletedAt = r.deleted_at
                local.updatedAt = r.updated_at ?? Date()
            }

            try self.purgeInvalidClients(debug: debug)
            try self.context.saveIfNeeded()
        }
    }

    private func upsertAddresses(_ remote: [AddressDTO], debug: Bool) async throws {
        if debug { print("⬇️ Addresses remote count:", remote.count) }

        try await context.perform {
            // кэш для быстрых связей
            let streetByRemoteId = self.buildStreetIndex()
            let clientByRemoteId = self.buildClientIndex()

            for r in remote {
                guard let client = clientByRemoteId[r.client_id] else { continue }
                guard let street = streetByRemoteId[r.street_id] else { continue }

                let local = self.findOrCreateAddress(remoteId: r.id)

                if !self.shouldApplyRemoteUpdate(remoteUpdatedAt: r.updated_at, localUpdatedAt: local.updatedAt) {
                    continue
                }

                local.client = client
                local.street = street

                local.house = r.house
                local.apartment = r.apartment
                local.entrance = r.entrance
                local.entranceType = r.entrance_type
                local.roomType = r.room_type
                local.floor = r.floor
                local.isPrimary = r.is_primary
                local.isPrivateHouse = r.is_private_house

                local.remoteId = r.id
                local.deletedAt = r.deleted_at
                local.updatedAt = r.updated_at ?? Date()
            }

            try self.context.saveIfNeeded()
        }
    }

    private func upsertTasks(_ remote: [TaskDTO], debug: Bool) async throws {
        if debug { print("⬇️ Tasks remote count:", remote.count) }

        try await context.perform { [self] in
            let clientByRemoteId = self.buildClientIndex()
            let addressByRemoteId = self.buildAddressIndex()

            for r in remote {
                guard let client = clientByRemoteId[r.client_id] else {
                    if debug { print("⚠️ Skip remote Task: missing client local mapping. remoteId=\(r.id)") }
                    continue
                }

                // scheduledAt is required
                let scheduledAt = r.scheduled_at

                // Validate address requirement
                if r.is_remote == false, r.address_id == nil {
                    if debug { print("⚠️ Skip remote Task: non-remote but address_id is nil. remoteId=\(r.id)") }
                    continue
                }

                let local = self.findOrCreateTask(remoteId: r.id)

                if !self.shouldApplyRemoteUpdate(remoteUpdatedAt: r.updated_at, localUpdatedAt: local.updatedAt) {
                    continue
                }

                local.client = client

                if let addrId = r.address_id {
                    local.address = addressByRemoteId[addrId]
                } else {
                    local.address = nil
                }

                local.scheduledAt = scheduledAt
                local.taskDescription = r.task_description
                local.paymentType = r.payment_type
                local.comment = r.comment

                local.isRemote = r.is_remote
                local.statusString = r.statusString

                local.contractAmount = r.contract_amount
                local.cost = r.cost
                local.extraPaymentValue = r.extra_payment

                local.totalAmount = r.total_amount

                local.remoteId = r.id
                local.deletedAt = r.deleted_at
                local.updatedAt = r.updated_at ?? Date()
            }

            try self.purgeInvalidTasks(debug: debug)
            try self.context.saveIfNeeded()
        }
    }

    // MARK: - CoreData find/create

    private func findOrCreateStreet(remoteId: UUID) -> Street {
        if let existing = fetchOne(Street.self, remoteId: remoteId) { return existing }
        let s = Street(context: context)
        s.remoteId = remoteId
        s.updatedAt = Date()
        return s
    }

    private func findOrCreateClient(remoteId: UUID) -> Client {
        if let existing = fetchOne(Client.self, remoteId: remoteId) { return existing }
        let c = Client(context: context)
        c.remoteId = remoteId
        c.updatedAt = Date()
        return c
    }

    private func findOrCreateAddress(remoteId: UUID) -> Address {
        if let existing = fetchOne(Address.self, remoteId: remoteId) { return existing }
        let a = Address(context: context)
        a.remoteId = remoteId
        a.updatedAt = Date()
        return a
    }

    private func findOrCreateTask(remoteId: UUID) -> TaskEntity {
        if let existing = fetchOne(TaskEntity.self, remoteId: remoteId) { return existing }
        let t = TaskEntity(context: context)
        t.remoteId = remoteId
        t.updatedAt = Date()
        return t
    }

    private func fetchOne<T: NSManagedObject>(_ type: T.Type, remoteId: UUID) -> T? {
        let req = NSFetchRequest<T>(entityName: String(describing: type))
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "remoteId == %@", remoteId as CVarArg)
        return try? context.fetch(req).first
    }

    // MARK: - Indexes for relations

    private func buildStreetIndex() -> [UUID: Street] {
        let req: NSFetchRequest<Street> = Street.fetchRequest()
        let items = (try? context.fetch(req)) ?? []
        return Dictionary(uniqueKeysWithValues: items.compactMap { s in
            guard let id = s.remoteId else { return nil }
            return (id, s)
        })
    }

    private func buildClientIndex() -> [UUID: Client] {
        let req: NSFetchRequest<Client> = Client.fetchRequest()
        let items = (try? context.fetch(req)) ?? []
        return Dictionary(uniqueKeysWithValues: items.compactMap { c in
            guard let id = c.remoteId else { return nil }
            return (id, c)
        })
    }

    private func buildAddressIndex() -> [UUID: Address] {
        let req: NSFetchRequest<Address> = Address.fetchRequest()
        let items = (try? context.fetch(req)) ?? []
        return Dictionary(uniqueKeysWithValues: items.compactMap { a in
            guard let id = a.remoteId else { return nil }
            return (id, a)
        })
    }

    // MARK: - Conflict rule

    /// Простейшее правило: применяем remote, только если remote.updated_at новее локального updatedAt.
    /// Если remote.updated_at нет (редко), считаем, что можно применить.
    private func shouldApplyRemoteUpdate(remoteUpdatedAt: Date?, localUpdatedAt: Date?) -> Bool {
        guard let r = remoteUpdatedAt else { return true }
        guard let l = localUpdatedAt else { return true }
        return r > l
    }
}

private extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        if hasChanges { try save() }
    }
}
