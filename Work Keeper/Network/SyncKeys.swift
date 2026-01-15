import Foundation



enum SyncKeys {
    // Legacy (global) keys — kept for backward compatibility
    static let lastPullAt = "sync.lastPullAt"
    static let lastPushAtStreets = "sync.lastPushAt.streets"
    static let lastPushAtClients = "sync.lastPushAt.clients"
    static let lastPushAtAddresses = "sync.lastPushAt.addresses"
    static let lastPushAtTasks = "sync.lastPushAt.tasks"

    // Per-owner key builder (fixes multi-account mixing)
    static func key(_ base: String, ownerId: UUID) -> String {
        "\(base).\(ownerId.uuidString)"
    }

    static func lastPullAt(ownerId: UUID) -> String { key(lastPullAt, ownerId: ownerId) }
    static func lastPushAtStreets(ownerId: UUID) -> String { key(lastPushAtStreets, ownerId: ownerId) }
    static func lastPushAtClients(ownerId: UUID) -> String { key(lastPushAtClients, ownerId: ownerId) }
    static func lastPushAtAddresses(ownerId: UUID) -> String { key(lastPushAtAddresses, ownerId: ownerId) }
    static func lastPushAtTasks(ownerId: UUID) -> String { key(lastPushAtTasks, ownerId: ownerId) }
}

// MARK: - Pull state

/// Legacy (global) pull state. Prefer the per-owner overload.
func loadLastPullAt() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPullAt) as? Date) ?? .distantPast
}

/// Legacy (global) pull state. Prefer the per-owner overload.
func saveLastPullAt(_ d: Date) {
    UserDefaults.standard.set(d, forKey: SyncKeys.lastPullAt)
}

/// Per-owner pull state (fixes multi-account mixing).
func loadLastPullAt(ownerId: UUID) -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPullAt(ownerId: ownerId)) as? Date) ?? .distantPast
}

/// Per-owner pull state (fixes multi-account mixing).
func saveLastPullAt(_ d: Date, ownerId: UUID) {
    UserDefaults.standard.set(d, forKey: SyncKeys.lastPullAt(ownerId: ownerId))
}
// MARK: - Push state


    


func loadLastPushAtStreets() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtStreets) as? Date) ?? .distantPast
}

func saveLastPushAtStreets(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtStreets)
}

func loadLastPushAtStreets(ownerId: UUID) -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtStreets(ownerId: ownerId)) as? Date) ?? .distantPast
}

func saveLastPushAtStreets(_ date: Date, ownerId: UUID) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtStreets(ownerId: ownerId))
}

func loadLastPushAtClients() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtClients) as? Date) ?? .distantPast
}

func saveLastPushAtClients(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtClients)
}

func loadLastPushAtClients(ownerId: UUID) -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtClients(ownerId: ownerId)) as? Date) ?? .distantPast
}

func saveLastPushAtClients(_ date: Date, ownerId: UUID) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtClients(ownerId: ownerId))
}

func loadLastPushAtAddresses() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtAddresses) as? Date) ?? .distantPast
}

func saveLastPushAtAddresses(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtAddresses)
}

func loadLastPushAtAddresses(ownerId: UUID) -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtAddresses(ownerId: ownerId)) as? Date) ?? .distantPast
}

func saveLastPushAtAddresses(_ date: Date, ownerId: UUID) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtAddresses(ownerId: ownerId))
}

func loadLastPushAtTasks() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtTasks) as? Date) ?? .distantPast
}

func saveLastPushAtTasks(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtTasks)
}

func loadLastPushAtTasks(ownerId: UUID) -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtTasks(ownerId: ownerId)) as? Date) ?? .distantPast
}

func saveLastPushAtTasks(_ date: Date, ownerId: UUID) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtTasks(ownerId: ownerId))
}

