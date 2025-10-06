import SwiftUI
import CoreData

struct IncomeRow: View {
    @Environment(\.managedObjectContext) private var context
  
    let year: Int
    /// 0 = "За год", 1...12 = месяцы

    let monthIndex: Int

    @State private var amount: Decimal = 0

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
    
   static let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    
    var body: some View {
        HStack {
            
            if title() == "За год" {
                
                
                Text(title())
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                
                Spacer()
                Text(formatted(amount))
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(title())
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                
                Spacer()
                Text(formatted(amount))
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
            
           
        }
        .padding(.vertical, 8)
        .onAppear(perform: compute)
        .onChange(of: year) { _ in compute() }
        .onChange(of: monthIndex) { _ in compute() }
        .task(id: year * 100 + monthIndex) {
            compute()
        }
    }

    private func compute() {
        if monthIndex == 0 {
            amount = totalIncome(context: context, year: year, month: nil, onlyCompleted: true, debug: false)
        } else {
            amount = totalIncome(context: context, year: year, month: monthIndex, onlyCompleted: true, debug: false)
        }
    }
}
