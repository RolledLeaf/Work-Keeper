import Foundation



enum SyncKeys {
    static let lastPullAt = "sync.lastPullAt"
}

func loadLastPullAt() -> Date {
    (UserDefaults.standard.object(forKey: SyncKeys.lastPullAt) as? Date) ?? .distantPast
}

func saveLastPullAt(_ d: Date) {
    UserDefaults.standard.set(d, forKey: SyncKeys.lastPullAt)
}
