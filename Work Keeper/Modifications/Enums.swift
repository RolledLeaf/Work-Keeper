import Foundation

enum TaskStatus: String, Identifiable, CaseIterable {
//    case all = "Все"
    case scheduled = "Запланированные"
    case completed = "Выполненные"
    case canceled = "Отменённые"
    
    var id: String { rawValue }
    
}
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
    case none
    
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .cash: return "Наличные"
        case .transfer: return "Перевод"
            case .none: return "Нет"
        }
    }
}

let userDefaults = UserDefaults.standard

enum UserDefaultsKeys: String, CaseIterable {
    case streetsSorting = "streetsSorting"
    case tasksFilter = "tasksFilter"
    case clientsSorting = "clientsSorting"
  
}

