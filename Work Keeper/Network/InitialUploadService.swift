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

    /// Incremental push for Streets (create/update/soft-delete).
    /// Uses a local lastPushAt checkpoint stored in UserDefaults.
    func pushStreets(ownerId: UUID, debug: Bool = true) async throws {
        let syncStartedAt = Date()
        let since = loadLastPushAtStreets()
        if debug { print("⬆️ Streets Push started. since=\(since)") }

        try await pushStreets(ownerId: ownerId, since: since, debug: debug)

        saveLastPushAtStreets(syncStartedAt)
        if debug { print("✅ Streets Push finished") }
    }

    // MARK: - Streets

    private func uploadStreets(ownerId: UUID, debug: Bool) async throws {
        let streets: [Street] = try await fetch(Street.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Streets to upload:", streets.count) }

        var processed = Set<String>()

        for s in streets {
            let trimmed = (s.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Normalize to avoid duplicates that differ only by case/whitespace
            let key = trimmed.lowercased()
            if processed.contains(key) {
                if debug { print("ℹ️ Skip duplicate local street in batch:", trimmed) }
                continue
            }
            processed.insert(key)

            // If it already exists remotely, just link remoteId.
            if let existing = try await streetStore.fetchByName(ownerId: ownerId, name: trimmed) {
                if debug { print("ℹ️ Link existing remote street:", trimmed) }
                try await context.perform {
                    s.remoteId = existing.id
                    s.updatedAt = Date()
                }
                try await saveIfNeeded()
                continue
            }

            // Otherwise create.
            let created = try await streetStore.create(name: trimmed, ownerId: ownerId)
            try await context.perform {
                s.remoteId = created.id
                s.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    /// Push streets changed since `since`.
    /// - Creates: remoteId == nil
    /// - Updates: remoteId != nil && deletedAt == nil && updatedAt > since
    /// - Soft-deletes: remoteId != nil && deletedAt != nil && updatedAt > since
    private func pushStreets(ownerId: UUID, since: Date, debug: Bool) async throws {
        // 1) Create new local streets that were never uploaded.
        let toCreate: [Street] = try await fetch(Street.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Streets to CREATE:", toCreate.count) }

        for s in toCreate {
            let trimmed = (s.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Avoid remote unique constraint violation: link if exists.
            if let existing = try await streetStore.fetchByName(ownerId: ownerId, name: trimmed) {
                if debug { print("ℹ️ Link existing remote street during push:", trimmed) }
                try await context.perform {
                    s.remoteId = existing.id
                    s.updatedAt = Date()
                }
                try await saveIfNeeded()
                continue
            }

            let created = try await streetStore.create(name: trimmed, ownerId: ownerId)
            try await context.perform {
                s.remoteId = created.id
                // Prefer server timestamp if available
                s.updatedAt = created.updated_at ?? Date()
            }
            try await saveIfNeeded()
        }

        // 2) Update edited streets.
        let toUpdate: [Street] = try await fetch(Street.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId != nil"),
            NSPredicate(format: "updatedAt > %@", since as NSDate)
        ]))
        if debug { print("⬆️ Streets to UPDATE:", toUpdate.count) }

        for s in toUpdate {
            guard let rid = s.remoteId else { continue }
            let trimmed = (s.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let updated = try await streetStore.update(streetId: rid, ownerId: ownerId, name: trimmed)
            try await context.perform {
                s.updatedAt = updated.updated_at ?? Date()
            }
            try await saveIfNeeded()
        }

        // 3) Soft-delete locally deleted streets.
        let toDelete: [Street] = try await fetch(Street.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "deletedAt != nil"),
            NSPredicate(format: "remoteId != nil"),
            NSPredicate(format: "updatedAt > %@", since as NSDate)
        ]))
        if debug { print("⬆️ Streets to SOFT-DELETE:", toDelete.count) }

        for s in toDelete {
            guard let rid = s.remoteId else { continue }
            let deletedAt = s.deletedAt ?? Date()
            try await streetStore.softDelete(streetId: rid, ownerId: ownerId, deletedAt: deletedAt)
            // No local changes needed; keep deletedAt as is.
        }
    }

    // MARK: - Clients

    private func uploadClients(ownerId: UUID, debug: Bool) async throws {
        let clients: [Client] = try await fetch(Client.self, predicate: NSPredicate(format: "deletedAt == nil AND remoteId == nil"))
        if debug { print("⬆️ Clients to upload:", clients.count) }

        var processedPhones = Set<String>()

        for c in clients {
            guard
                let first = c.firstName?.trimmingCharacters(in: .whitespacesAndNewlines),
                !first.isEmpty,
                let rawPhone = c.phone?.trimmingCharacters(in: .whitespacesAndNewlines),
                !rawPhone.isEmpty
            else {
                if debug { print("⚠️ Skip client: missing firstName/phone. localId=\(c.id)") }
                continue
            }

            // Normalize phone for de-duplication within this batch (remove common formatting chars)
            let normalizedPhone = rawPhone
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")

            if processedPhones.contains(normalizedPhone) {
                if debug { print("ℹ️ Skip duplicate local client in batch. phone:", rawPhone) }
                continue
            }
            processedPhones.insert(normalizedPhone)

            // If it already exists remotely (unique phone), just link remoteId.
            if let existing = try await clientStore.fetchByPhone(ownerId: ownerId, phone: rawPhone) {
                if debug { print("ℹ️ Link existing remote client. phone:", rawPhone) }
                try await context.perform {
                    c.remoteId = existing.id
                    c.updatedAt = Date()
                }
                try await saveIfNeeded()
                continue
            }

            // Otherwise create.
            let created = try await clientStore.create(
                firstName: first,
                lastName: c.lastName,
                phone: rawPhone,
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

        // De-dup within this upload batch
        var processedKeys = Set<String>()

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
            // 3) house required
            let house = (a.house ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !house.isEmpty else {
                if debug { print("⚠️ Skip address: missing house. localId=\(a.objectID)") }
                continue
            }

            // Normalize key for de-duplication (house + optional apartment)
            let apt = (a.apartment ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let key = "\(clientId.uuidString)|\(streetId.uuidString)|\(house.lowercased())|\(apt.lowercased())"
            if processedKeys.contains(key) {
                if debug { print("ℹ️ Skip duplicate local address in batch:", key) }
                continue
            }
            processedKeys.insert(key)

            // Try to find an existing remote address with the same identity.
            let candidates = try await addressStore.fetchCandidates(ownerId: ownerId, clientId: clientId, streetId: streetId, house: house)

            let match = candidates.first(where: {
                // Match optional fields strictly after trimming. Note: remote empty strings might be stored as null.
                func norm(_ s: String?) -> String { (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
                return norm($0.apartment).lowercased() == apt.lowercased()
                    && norm($0.entrance).lowercased() == norm(a.entrance).lowercased()
                    && norm($0.entrance_type).lowercased() == norm(a.entranceType).lowercased()
                    && norm($0.room_type).lowercased() == norm(a.roomType).lowercased()
                    && norm($0.floor).lowercased() == norm(a.floor).lowercased()
                    && $0.is_private_house == a.isPrivateHouse
            })

            if let existing = match {
                if debug { print("ℹ️ Link existing remote address. id=\(existing.id)") }

                // If local says it's primary, ensure remote becomes primary.
                if a.isPrimary {
                    try await addressStore.update(
                        addressId: existing.id,
                        clientId: clientId,
                        payload: AddressUpdateDTO(
                            street_id: streetId,
                            house: house,
                            apartment: a.apartment,
                            entrance: a.entrance,
                            entrance_type: a.entranceType,
                            room_type: a.roomType,
                            floor: a.floor,
                            is_primary: true,
                            is_private_house: a.isPrivateHouse
                        )
                    )
                }

                try await context.perform {
                    a.remoteId = existing.id
                    a.updatedAt = Date()
                }
                try await saveIfNeeded()
                continue
            }

            // Otherwise create.
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

        // De-dup within this upload batch
        var processedKeys = Set<String>()

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

            let desc = (t.taskDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let descKey = desc.lowercased()
            let addrKey = addressId?.uuidString ?? "<nil>"
            let key = "\(clientId.uuidString)|\(scheduledAt.timeIntervalSince1970)|\(status)|\(isRemote ? 1 : 0)|\(addrKey)|\(descKey)"

            if processedKeys.contains(key) {
                if debug { print("ℹ️ Skip duplicate local task in batch:", key) }
                continue
            }
            processedKeys.insert(key)

            // Try to link an existing remote task (same client + exact scheduled_at, then match by status/isRemote/address/description).
            let candidates = try await taskStore.fetchCandidates(ownerId: ownerId, clientId: clientId, scheduledAt: scheduledAt)

            let match = candidates.first(where: { r in
                let rStatus = r.statusString.trimmingCharacters(in: .whitespacesAndNewlines)
                let rDesc = (r.task_description ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let rAddr = r.address_id?.uuidString ?? "<nil>"
                return rStatus == status
                    && r.is_remote == isRemote
                    && rAddr == addrKey
                    && rDesc == descKey
            })

            if let existing = match {
                if debug { print("ℹ️ Link existing remote task. id=\(existing.id)") }
                try await context.perform {
                    t.remoteId = existing.id
                    t.updatedAt = Date()
                }
                try await saveIfNeeded()
                continue
            }

            // Otherwise create.
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
                extra_payment: t.extraPaymentValue,
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
