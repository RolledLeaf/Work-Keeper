import SwiftUI

struct ClientsView: View {
    
    @ObservedObject var viewModel: ClientsStatViewModel
    
    let year: Int

    private let shortMonths: [String] = ["За год", "Я", "Ф", "М", "А", "М", "И", "И", "А", "С", "О", "Н", "Д"]
    
    private let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
 
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Color.white
                    
                    Text("За всё время — \(format(viewModel.allClientsCount))")
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
                    // 0 — за год
                    ClientsStatRow(viewModel: viewModel, title: months[0], year: year, monthIndex: 0)
                        .listRowSeparator(.hidden)

                    // 1..12 — месяцы
                    ForEach(1...12, id: \.self) { m in
                        ClientsStatRow(viewModel: viewModel, title: months[m], year: year, monthIndex: m)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 10)

                
                
                
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadAllClientsCount()
            viewModel.loadMonthlyActive(year: year)
        }
    }


private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
    return f.string(from: (value as Int) as NSNumber) ?? "0"
    }}
