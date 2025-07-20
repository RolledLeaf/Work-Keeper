import SwiftUI

extension Double {
    func formattedCurrency(symbol: String = "₽") -> String {
        self == floor(self) ?
        "\(String(format: "%.0f", self)) \(symbol)" :
        "\(String(format: "%.2f", self)) \(symbol)"
    }
}
