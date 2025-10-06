import SwiftUI
import CoreData

struct IncomeRow: View {
    @ObservedObject var viewModel: IncomeViewModel
  
    let year: Int
    /// 0 = "За год", 1...12 = месяцы

    let monthIndex: Int
    
    static let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

    private var computedAmount: Decimal {
        if monthIndex == 0 {
            return viewModel.yearIncome
        }
        let idx = monthIndex - 1
        guard idx >= 0 && idx < viewModel.monthlyIncome.count else { return 0 }
        return viewModel.monthlyIncome[idx]
    }

    private func title() -> String {
        Self.months[monthIndex]
    }

    private func formatted(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "RUB"
        f.maximumFractionDigits = 0
        return f.string(from: value as NSDecimalNumber) ?? "0 ₽"
    }
    

    
    
    var body: some View {
        HStack {
            
            if title() == "За год" {
                
                
                Text(title())
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                
                Spacer()
                Text(formatted(computedAmount))
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(title())
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                
                Spacer()
                Text(formatted(computedAmount))
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
            
           
        }
        .padding(.vertical, 8)
       
    }


}
