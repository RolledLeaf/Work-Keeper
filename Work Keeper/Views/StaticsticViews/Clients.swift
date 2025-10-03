import SwiftUI

struct ClientsView: View {
    
    @StateObject var viewModel = ClientsStatViewModel()
    
    let year: Int
    
    

    
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

                Spacer()
            }
        }
        .onAppear {
            viewModel.loadAllClientsCount()
        }
    }


private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
    return f.string(from: (value as Int) as NSNumber) ?? "0"
    }}
