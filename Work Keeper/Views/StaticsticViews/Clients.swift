import SwiftUI
import Charts

struct Income1: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}


struct IncomeChartView: View {
    static let months: [String] = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    
    let data: [Income1] = [
        .init(month: "Янв", amount: 1200),
        .init(month: "Фев", amount: 1800),
        .init(month: "Мар", amount: 900),
        .init(month: "Апр", amount: 1500)
    ]
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Месяц", item.month),
                y: .value("Доход", item.amount)
            )
            .foregroundStyle(by: .value("Месяц", item.month)) // разный цвет по месяцам
        }
        .frame(height: 250)
        .padding()
        
        Text("Это круто")
    }
}

#Preview {
    IncomeChartView()
}


