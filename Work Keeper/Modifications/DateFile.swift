import Foundation

extension DateFormatter {
    
    static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMddyyyy")
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("dd.MM.YY")
        return formatter
    }()
    
    static let timeOnlyFormatter: DateFormatter = {
         let formatter = DateFormatter()
        formatter.locale = .current
         formatter.setLocalizedDateFormatFromTemplate("HH:mm")
         return formatter
     }()
    
    
}


extension Date {
    func formattedAsDate() -> String {
        DateFormatter.taskDateFormatter.string(from: self)
        
    }
    
    func formattedAsShortDate() -> String {
        DateFormatter.shortDateFormatter.string(from: self)
    }
    
    func formattedAsTime() -> String {
        DateFormatter.timeOnlyFormatter.string(from: self)
    }
    
    var formattedDateString: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: self)
        }

        var formattedTimeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: self)
        }
}

extension Date {
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}


