import SwiftUI



struct StreetRow: View {
    let street: String
       let isFirst: Bool
       let isLast: Bool
    
    var body: some View {
        
        ZStack {
            Color.custom(.addressListGray)?.ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text(street)
                        .padding(.leading, 15)
                    Spacer()
                }
                Spacer()
                Rectangle()
                    .opacity(isLast ? 0 : 1)
                    .frame(height: 1)
                    .padding(.leading, 15)
                    .foregroundColor(.custom(.separatorLineGray))
            }
            
        }
        
        .listRowInsets(EdgeInsets())
        .cornerRadius(7,corners: isFirst && isLast ? [.allCorners] :
                        isFirst ? [.topLeft, .topRight] :
                        isLast ? [.bottomLeft, .bottomRight] :
                        [])
        .listRowSeparator(.hidden)
    }
}

#Preview {
    StreetsListView()
}
