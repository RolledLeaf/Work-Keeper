import Foundation

enum Status: String, CaseIterable {
    case scheduled
    case completed
    case canceled
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


enum PaymentType: String, Codable {
    case transfer
    case cash
    
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .cash: return "Наличные"
        case .transfer: return "Перевод"
        }
    }
}
