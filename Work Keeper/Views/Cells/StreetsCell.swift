import SwiftUI

struct StreetRow: View {
    
    let street: Street
     
    
    var body: some View {
        
        ZStack {
            Color.custom(.addressListGray).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text(street.name ?? "без названия")
                        .padding(.leading, 15)
                    Spacer()
                }
                Spacer()
                Rectangle()
                    
                    .frame(height: 1)
                    .padding(.leading, 15)
                    .foregroundColor(.custom(.separatorLineGray))
            }
            
        }
        
        .listRowInsets(EdgeInsets())
        .cornerRadius(7)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
