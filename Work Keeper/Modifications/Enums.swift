import Foundation

enum TaskStatus: String, Identifiable, CaseIterable {
    case all = "Все"
    case scheduled = "Запланированные"
    case completed = "Выполненные"
    case canceled = "Отменённые"
    
    var id: String { rawValue }
    
}

enum SortOption: String, CaseIterable, Identifiable {
    case nameAZ = "По именам А-Я"
    case nameZA = "По именам Я-А"
    case addressAZ = "По адресам А-Я"
    case addressZA = "По адресам Я-А"
    case moreCompleted = "Больше выполненных заданий"
    case lessCompleted = "Меньше выполненных заданий"
    
    var id: String { rawValue }
}


//Menu {
//    ForEach(TaskStatus.allCases, id: \.self) { status in
//        Button(action: { selectedStatus = status }) {
//            Label(status.localizedName, systemImage: selectedStatus == status ? "checkmark" : "")
//        }
//    }
//} label: {
//    Label("Фильтр", systemImage: "line.3.horizontal.decrease.circle")
//}


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
