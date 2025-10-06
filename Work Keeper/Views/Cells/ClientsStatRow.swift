import SwiftUI



struct ClientsStatRow: View {
   
    @ObservedObject var viewModel: ClientsStatViewModel

    let title: String
    let year: Int
    /// 0 = "За год", 1...12 = месяцы
    let monthIndex: Int

 
    
    private var computedAmount: Int {
        if monthIndex == 0 {
            return viewModel.yearActiveClientsCount
        }
        let idx = monthIndex - 1
        guard idx >= 0 && idx < viewModel.monthlyActiveCounts.count else { return 0 }
        return viewModel.monthlyActiveCounts[idx]
    }
  

    var body: some View {
        HStack {
            if title == "За год" {
                Text(title)
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                Spacer()
                Text("\(computedAmount)")
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Text(title)
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                Spacer()
                Text("\(computedAmount)")
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 8)
   
    }
}
