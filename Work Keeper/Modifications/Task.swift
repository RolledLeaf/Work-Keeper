import Foundation

extension Task {
    var status: Status {
        get {
            Status(rawValue: statusString ?? "") ?? .scheduled
        }
        set {
            statusString = newValue.rawValue
        }
    }
}
