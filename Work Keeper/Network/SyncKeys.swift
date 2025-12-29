import Foundation



enum SyncKeys {
    static let lastPullAt = "sync.lastPullAt"
    static let lastPushAtStreets = "sync.lastPushAt.streets"
    static let lastPushAtClients = "sync.lastPushAt.clients"
    static let lastPushAtAddresses = "sync.lastPushAt.addresses"
    static let lastPushAtTasks = "sync.lastPushAt.tasks"
}

func loadLastPullAt() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPullAt) as? Date) ?? .distantPast
}

func saveLastPullAt(_ d: Date) {
    UserDefaults.standard.set(d, forKey: SyncKeys.lastPullAt)
}
// MARK: - Push state


    


func loadLastPushAtStreets() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtStreets) as? Date) ?? .distantPast
}

func saveLastPushAtStreets(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtStreets)
}

func loadLastPushAtClients() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtClients) as? Date) ?? .distantPast
}

func saveLastPushAtClients(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtClients)
}

func loadLastPushAtAddresses() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtAddresses) as? Date) ?? .distantPast
}

func saveLastPushAtAddresses(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtAddresses)
}

func loadLastPushAtTasks() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPushAtTasks) as? Date) ?? .distantPast
}

func saveLastPushAtTasks(_ date: Date) {
    UserDefaults.standard.set(date, forKey: SyncKeys.lastPushAtTasks)
}

