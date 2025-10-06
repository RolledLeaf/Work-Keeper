import SwiftUI
import Charts

struct Income: Identifiable {
    let id = UUID()
    let month: String
    let amount: Decimal
}

struct IncomeView: View {
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var viewModel: IncomeViewModel
   
    @State private var monthly: [Income] = []
    @State private var amount: Decimal = 0
   
    static let months: [String] = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    
    let year: Int
   
    
    var body: some View {
        

        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Color.white
                    
                    Text("За всё время — \(format(viewModel.total)) ₽")
                        .font(Font.custom(SFPro.bold.rawValue, size: 24))
                    
                        .padding(10)
                }
                .frame(height: 50)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .padding(.horizontal, 10)
                )

                
                Chart(monthly) { item in
                    BarMark(
                        x: .value("Месяц", item.month),
                        y: .value("Доход", item.amount)
                    )
                    .foregroundStyle(by: .value("Месяц", item.month))
                    
                }
                .frame(height: 220)
                .padding(.horizontal)
                
          
            
            
                
                   
                List {
                    ForEach(0..<IncomeRow.months.count, id: \.self) { idx in
                        IncomeRow( viewModel: viewModel, year: year, monthIndex: idx)
                    }
                }
                .listRowSeparator(.hidden)
                .listStyle(PlainListStyle())
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .id(year)
                
                Spacer()
            }
          
            
        }
        .onAppear {
            viewModel.loadTotal()
            viewModel.loadMonthlyIncome(year: year)
        }
        .task(id: year) {
            monthly = (1...12).map { m in
                let amount = totalIncome(context: context, year: year, month: m, onlyCompleted: true, debug: false)
                return Income(month: Self.months[m-1], amount: amount)
            }
        }
        
        
    }
    private func format(_ value: Decimal) -> String {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = " "
            return f.string(from: value as NSDecimalNumber) ?? "0"
        }}

