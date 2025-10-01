import SwiftUI

struct IncomeView: View {
    @ObservedObject var viewModel: IncomeViewModel
    
    
    
    var body: some View {
        
        var months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
        
        
        
        
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
                   
                
                Spacer()
            }
          
            
        }
        
        
        
    }
    private func format(_ value: Decimal) -> String {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = " "
            return f.string(from: value as NSDecimalNumber) ?? "0"
        }}

