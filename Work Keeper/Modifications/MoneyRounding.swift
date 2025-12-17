import SwiftUI

extension Double {
//    func formattedCurrency(symbol: String = "₽") -> String {
//        self == floor(self) ?
//        "\(String(format: "%.0f", self)) \(symbol)" :
//        "\(String(format: "%.2f", self)) \(symbol)"
//    }
    
    func formattedCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
              formatter.groupingSeparator = " " // пробелы
              formatter.decimalSeparator = ","
        
             if self == floor(self) {
                 formatter.maximumFractionDigits = 0
                 formatter.minimumFractionDigits = 0
             } else {
                 formatter.maximumFractionDigits = 2
                 formatter.minimumFractionDigits = 2
             }

             return "\(formatter.string(for: self) ?? "\(self)")"
         }
}
    


