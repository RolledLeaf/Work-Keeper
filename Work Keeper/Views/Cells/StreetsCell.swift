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
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                //action
            }) {
                Label {
                    Text("Редактировать")
                        .font(.custom(SFPro.regular.rawValue, size: 17))
                } icon: {
                    Image("pen")
                }
            }
            
            Button(role: .destructive) {
                    // действие удаления
                } label: {
                Label {
                    Text("Удалить")
                } icon: {
                    Image(systemName: "trash")
                        
                }
            }
        }
    }
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
