import SwiftUI

struct IncomeView: View {
    @ObservedObject var viewModel: IncomeViewModel
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
                   
                List {
                    ForEach(0..<IncomeRow.months.count, id: \.self) { idx in
                        IncomeRow(viewModel: viewModel, year: year, monthIndex: idx)
                    }
                }
                .listRowSeparator(.hidden)
                .listStyle(PlainListStyle())
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                Spacer()
            }
          
            
        }
        .onAppear {
            viewModel.loadTotal()
        }
        
        
    }
    private func format(_ value: Decimal) -> String {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = " "
            return f.string(from: value as NSDecimalNumber) ?? "0"
        }}

