import Foundation



enum SyncKeys {
    static let lastPullAt = "sync.lastPullAt"
    static let lastPushAtStreets = "sync.lastPushAt.streets"
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

