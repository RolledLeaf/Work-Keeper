import Foundation

enum Status: String, CaseIterable {
    case scheduled
    case completed
    case canceled
}

enum PaymentMethod: String, Codable {
    case creditCard
    case cash
}


extension Status {
    var title: String {
        switch self {
        case .scheduled: return "Назначено"
        case .completed: return "Выполнено"
        case .canceled:  return "Отменено"
        }
    }
}
