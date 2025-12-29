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

    func pushClients(ownerId: UUID, debug: Bool = true) async throws {
        let syncStartedAt = Date()
        let since = loadLastPushAtClients()
        if debug { print("⬆️ Clients Push started. since=\(since)") }

        try await pushClients(ownerId: ownerId, since: since, debug: debug)

        saveLastPushAtClients(syncStartedAt)
        if debug { print("✅ Clients Push finished") }
    }

    func pushAddresses(ownerId: UUID, debug: Bool = true) async throws {
        let syncStartedAt = Date()
        let since = loadLastPushAtAddresses()
        if debug { print("⬆️ Addresses Push started. since=\(since)") }

        try await pushAddresses(ownerId: ownerId, since: since, debug: debug)

        saveLastPushAtAddresses(syncStartedAt)
        if debug { print("✅ Addresses Push finished") }
    }

    func pushTasks(ownerId: UUID, debug: Bool = true) async throws {
        let syncStartedAt = Date()
        let since = loadLastPushAtTasks()
        if debug { print("⬆️ Tasks Push started. since=\(since)") }

        try await pushTasks(ownerId: ownerId, since: since, debug: debug)

        saveLastPushAtTasks(syncStartedAt)
        if debug { print("✅ Tasks Push finished") }
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
                    s.updatedAt = existing.updated_at ?? Date()
                    s.needsSync = false
                }
                try await saveIfNeeded()
                continue
            }

            // Otherwise create.
            let created = try await streetStore.create(name: trimmed, ownerId: ownerId)
            try await context.perform {
                s.remoteId = created.id
                s.updatedAt = created.updated_at ?? Date()
                s.needsSync = false
            }
            try await saveIfNeeded()
        }
    }

    /// Push streets changed since `since`, using needsSync flag.
    private func pushStreets(ownerId: UUID, since: Date, debug: Bool) async throws {
        // NOTE: `updatedAt` is a business/merge timestamp and must NOT be used as a dirty flag.
        // We push only objects explicitly marked as needing sync.

        // 1) Create new local streets that were never uploaded.
        let toCreate: [Street] = try await fetch(Street.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId == nil")
        ]))
        if debug { print("⬆️ Streets to CREATE:", toCreate.count) }

        for s in toCreate {
            let trimmed = (s.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Avoid remote unique constraint violation: link if exists.
            if let existing = try await streetStore.fetchByName(ownerId: ownerId, name: trimmed) {
                if debug { print("ℹ️ Link existing remote street during push:", trimmed) }
                try await context.perform {
                    s.remoteId = existing.id
                    s.updatedAt = existing.updated_at ?? Date()
                    s.needsSync = false
                }
                try await saveIfNeeded()
                continue
            }

            let created = try await streetStore.create(name: trimmed, ownerId: ownerId)
            try await context.perform {
                s.remoteId = created.id
                // Prefer server timestamp if available
                s.updatedAt = created.updated_at ?? Date()
                s.needsSync = false
            }
            try await saveIfNeeded()
        }

        // 2) Update edited streets.
        let toUpdate: [Street] = try await fetch(Street.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Streets to UPDATE:", toUpdate.count) }

        for s in toUpdate {
            guard let rid = s.remoteId else { continue }
            let trimmed = (s.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let updated = try await streetStore.update(streetId: rid, ownerId: ownerId, name: trimmed)
            try await context.perform {
                s.updatedAt = updated.updated_at ?? Date()
                s.needsSync = false
            }
            try await saveIfNeeded()
        }

        // 3) Soft-delete locally deleted streets.
        let toDelete: [Street] = try await fetch(Street.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt != nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Streets to SOFT-DELETE:", toDelete.count) }

        for s in toDelete {
            guard let rid = s.remoteId else { continue }
            let deletedAt = s.deletedAt ?? Date()
            try await streetStore.softDelete(streetId: rid, ownerId: ownerId, deletedAt: deletedAt)

            // Mark as synced after successful remote soft-delete.
            try await context.perform {
                s.needsSync = false
                // Keep local deletedAt; updatedAt becomes the moment we confirmed sync.
                s.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Clients

    /// Push clients changed since `since`, using needsSync flag.
    private func pushClients(ownerId: UUID, since: Date, debug: Bool) async throws {
        _ = since // checkpoint is kept for logging; dirty tracking uses needsSync.

        // CREATE
        let toCreate: [Client] = try await fetch(Client.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId == nil")
        ]))
        if debug { print("⬆️ Clients to CREATE:", toCreate.count) }

        for c in toCreate {
            let first = (c.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let rawPhone = (c.phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !first.isEmpty, !rawPhone.isEmpty else { continue }

            // Link by unique phone if already exists
            if let existing = try await clientStore.fetchByPhone(ownerId: ownerId, phone: rawPhone) {
                if debug { print("ℹ️ Link existing remote client during push. phone:", rawPhone) }
                try await context.perform {
                    c.remoteId = existing.id
                    c.updatedAt = existing.updated_at ?? Date()
                    c.needsSync = false
                }
                try await saveIfNeeded()
                continue
            }

            let created = try await clientStore.create(
                firstName: first,
                lastName: c.lastName,
                phone: rawPhone,
                comment: c.comment,
                ownerId: ownerId
            )

            try await context.perform {
                c.remoteId = created.id
                c.updatedAt = created.updated_at ?? Date()
                c.needsSync = false
            }
            try await saveIfNeeded()
        }

        // UPDATE
        let toUpdate: [Client] = try await fetch(Client.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Clients to UPDATE:", toUpdate.count) }

        for c in toUpdate {
            guard let rid = c.remoteId else { continue }
            let first = (c.firstName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let rawPhone = (c.phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !first.isEmpty, !rawPhone.isEmpty else { continue }

            let updated = try await clientStore.update(
                clientId: rid,
                ownerId: ownerId,
                firstName: first,
                lastName: c.lastName,
                phone: rawPhone,
                comment: c.comment
            )

            try await context.perform {
                c.updatedAt = updated.updated_at ?? Date()
                c.needsSync = false
            }
            try await saveIfNeeded()
        }

        // SOFT DELETE
        let toDelete: [Client] = try await fetch(Client.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt != nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Clients to SOFT-DELETE:", toDelete.count) }

        for c in toDelete {
            guard let rid = c.remoteId else { continue }
            let deletedAt = c.deletedAt ?? Date()
            try await clientStore.softDelete(clientId: rid, ownerId: ownerId, deletedAt: deletedAt)

            try await context.perform {
                c.needsSync = false
                c.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

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
                    c.updatedAt = existing.updated_at ?? Date()
                    c.needsSync = false
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
                c.needsSync = false
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Addresses

    /// Push addresses changed since `since`, using needsSync flag.
    private func pushAddresses(ownerId: UUID, since: Date, debug: Bool) async throws {
        _ = since

        // CREATE
        let toCreate: [Address] = try await fetch(Address.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId == nil")
        ]))
        if debug { print("⬆️ Addresses to CREATE:", toCreate.count) }

        for a in toCreate {
            guard let client = a.client, let clientId = client.remoteId else { continue }
            guard let street = a.street, let streetId = street.remoteId else { continue }
            let house = (a.house ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !house.isEmpty else { continue }

            // Try to link an existing remote address candidate
            let candidates = try await addressStore.fetchCandidates(ownerId: ownerId, clientId: clientId, streetId: streetId, house: house)
            func norm(_ s: String?) -> String { (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            let apt = norm(a.apartment)

            let match = candidates.first(where: {
                return norm($0.apartment) == apt
                    && norm($0.entrance) == norm(a.entrance)
                    && norm($0.entrance_type) == norm(a.entranceType)
                    && norm($0.room_type) == norm(a.roomType)
                    && norm($0.floor) == norm(a.floor)
                    && $0.is_private_house == a.isPrivateHouse
            })

            if let existing = match {
                // Ensure remote primary if needed
                if a.isPrimary {
                    try await addressStore.update(
                        addressId: existing.id,
                        ownerId: ownerId,
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
                    a.updatedAt = existing.updated_at ?? Date()
                    a.needsSync = false
                }
                try await saveIfNeeded()
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
                a.updatedAt = created.updated_at ?? Date()
                a.needsSync = false
            }
            try await saveIfNeeded()
        }

        // UPDATE
        let toUpdate: [Address] = try await fetch(Address.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Addresses to UPDATE:", toUpdate.count) }

        for a in toUpdate {
            guard let rid = a.remoteId else { continue }
            guard let client = a.client, let clientId = client.remoteId else { continue }
            guard let street = a.street, let streetId = street.remoteId else { continue }
            let house = (a.house ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !house.isEmpty else { continue }

            let updated = try await addressStore.update(
                addressId: rid,
                ownerId: ownerId,
                clientId: clientId,
                payload: AddressUpdateDTO(
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
            )

            try await context.perform {
                a.updatedAt = updated.updated_at ?? Date()
                a.needsSync = false
            }
            try await saveIfNeeded()
        }

        // SOFT DELETE
        let toDelete: [Address] = try await fetch(Address.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt != nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Addresses to SOFT-DELETE:", toDelete.count) }

        for a in toDelete {
            guard let rid = a.remoteId else { continue }
            let deletedAt = a.deletedAt ?? Date()
            try await addressStore.softDelete(addressId: rid, ownerId: ownerId, deletedAt: deletedAt)

            try await context.perform {
                a.needsSync = false
                a.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

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
                        ownerId: ownerId,
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
                    a.updatedAt = existing.updated_at ?? Date()
                    a.needsSync = false
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
                a.updatedAt = created.updated_at ?? Date()
                a.needsSync = false
            }
            try await saveIfNeeded()
        }
    }

    // MARK: - Tasks

    /// Push tasks changed since `since`, using needsSync flag.
    private func pushTasks(ownerId: UUID, since: Date, debug: Bool) async throws {
        _ = since

        // CREATE
        let toCreate: [TaskEntity] = try await fetch(TaskEntity.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId == nil")
        ]))
        if debug { print("⬆️ Tasks to CREATE:", toCreate.count) }

        for t in toCreate {
            guard let client = t.client, let clientId = client.remoteId else { continue }
            guard let scheduledAt = t.scheduledAt else { continue }
            let status = (t.statusString ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !status.isEmpty else { continue }

            let allowedStatuses: Set<String> = ["scheduled", "completed", "canceled"]
            guard allowedStatuses.contains(status) else { continue }

            let isRemote = t.isRemote
            let addressId: UUID?
            if isRemote {
                addressId = nil
            } else {
                guard let addr = t.address, let rid = addr.remoteId else { continue }
                addressId = rid
            }

            // De-dup/link candidates similarly to initial upload
            let candidates = try await taskStore.fetchCandidates(ownerId: ownerId, clientId: clientId, scheduledAt: scheduledAt)
            let desc = (t.taskDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let descKey = desc.lowercased()
            let addrKey = addressId?.uuidString ?? "<nil>"

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
                try await context.perform {
                    t.remoteId = existing.id
                    t.updatedAt = existing.updated_at ?? Date()
                    t.needsSync = false
                }
                try await saveIfNeeded()
                continue
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
                extra_payment: t.extraPaymentValue,
                client_id: clientId,
                address_id: addressId
            )

            let created = try await taskStore.create(payload)

            try await context.perform {
                t.remoteId = created.id
                t.updatedAt = created.updated_at ?? Date()
                t.needsSync = false
            }
            try await saveIfNeeded()
        }

        // UPDATE
        let toUpdate: [TaskEntity] = try await fetch(TaskEntity.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt == nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Tasks to UPDATE:", toUpdate.count) }

        for t in toUpdate {
            guard let rid = t.remoteId else { continue }
            guard let client = t.client, let clientId = client.remoteId else { continue }
            guard let scheduledAt = t.scheduledAt else { continue }
            let status = (t.statusString ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !status.isEmpty else { continue }

            let allowedStatuses: Set<String> = ["scheduled", "completed", "canceled"]
            guard allowedStatuses.contains(status) else { continue }

            let isRemote = t.isRemote
            let addressId: UUID?
            if isRemote {
                addressId = nil
            } else {
                guard let addr = t.address, let ridAddr = addr.remoteId else { continue }
                addressId = ridAddr
            }

            let payload = TaskUpdateDTO(
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

            let updated = try await taskStore.update(taskId: rid, ownerId: ownerId, payload: payload)

            try await context.perform {
                t.updatedAt = updated.updated_at ?? Date()
                t.needsSync = false
            }
            try await saveIfNeeded()
        }

        // SOFT DELETE
        let toDelete: [TaskEntity] = try await fetch(TaskEntity.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "needsSync == YES"),
            NSPredicate(format: "deletedAt != nil"),
            NSPredicate(format: "remoteId != nil")
        ]))
        if debug { print("⬆️ Tasks to SOFT-DELETE:", toDelete.count) }

        for t in toDelete {
            guard let rid = t.remoteId else { continue }
            let deletedAt = t.deletedAt ?? Date()
            try await taskStore.softDelete(taskId: rid, ownerId: ownerId, deletedAt: deletedAt)

            try await context.perform {
                t.needsSync = false
                t.updatedAt = Date()
            }
            try await saveIfNeeded()
        }
    }

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
                    t.updatedAt = existing.updated_at ?? Date()
                    t.needsSync = false
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
                t.updatedAt = created.updated_at ?? Date()
                t.needsSync = false
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
