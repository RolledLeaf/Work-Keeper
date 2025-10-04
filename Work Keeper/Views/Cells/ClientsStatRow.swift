import SwiftUI
import CoreData


struct ClientsStatRow: View {
    @Environment(\.managedObjectContext) private var context
    private let store = ClientStore()

    let title: String
    let year: Int
    /// 0 = "За год", 1...12 = месяцы
    let monthIndex: Int

 
    
    @State private var amount: Int = 0
  

    var body: some View {
        HStack {
            if title == "За год" {
                Text(title)
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                Spacer()
                Text("\(amount)")
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(title)
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                Spacer()
                Text("\(amount)")
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 8)
        .task(id: year * 100 + monthIndex) {
            if monthIndex == 0 {
                amount = store.distinctClientsCount(year: year, month: nil, onlyCompleted: true, dateKey: "scheduledAt", debug: false)
            } else {
                amount = store.distinctClientsCount(year: year, month: monthIndex, onlyCompleted: true, dateKey: "scheduledAt", debug: false)
            }
        }
    }
}
