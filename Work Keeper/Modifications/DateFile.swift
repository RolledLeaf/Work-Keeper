import Foundation

extension DateFormatter {
    
   static let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
       formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
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
    
    func formattedAsTime() -> String {
        DateFormatter.timeOnlyFormatter.string(from: self)
    }
}
