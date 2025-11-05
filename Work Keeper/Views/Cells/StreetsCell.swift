import SwiftUI

struct StreetRow: View {
    @State private var showEditStreetView = false
    @State private var showDeleteStreetAlert = false
  
    @State private var streetForEdit: Street?
    @State private var lastDeletedStreet = ""
    @State private var lastEditedStreet = ""
    
    @ObservedObject var viewModel: StreetListViewModel
    
    let street: Street
     
    
    var body: some View {
        
        ZStack {
            Color.custom(.addressListGray).ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text(highlighted(street.name ?? "без названия", query: viewModel.searchText, highlightColor: .highlightBlue))
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
                streetForEdit = street
                showEditStreetView = true
                viewModel.previousStreetName = street.name ?? ""
       
            }) {
                Label {
                    Text("Редактировать")
                        .font(.custom(SFPro.regular.rawValue, size: 17))
                } icon: {
                    Image("pen")
                }
            }
            
            Button(role: .destructive) {
                showDeleteStreetAlert = true
                } label: {
                Label {
                    Text("Удалить")
                } icon: {
                    Image(systemName: "trash")
                        
                }
            }
        }
        .confirmationDialog("Удалить эту улицу?", isPresented: $showDeleteStreetAlert, titleVisibility: .visible) {
            Button("Удалить", role: .destructive) {
                let streetName = street.name ?? "без названия"
                lastDeletedStreet = streetName
                viewModel.delete(street, name: streetName)
                
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    viewModel.streetWasDeleted = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.streetWasDeleted = false
                    }
                }
                
                viewModel.loadStreets()
                
           
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Улица будет удалена безвозвратно")
        }
        
        
        .sheet(item: $streetForEdit, onDismiss: {
            viewModel.loadStreets()
        }) { street in
            EditStreetView(onEdit: { updatedStreetName in
                lastEditedStreet = updatedStreetName
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    viewModel.streetWasEdited = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.streetWasEdited = false
                    }
                }
                    
            }, viewModel: viewModel, street: street)
        }
    }
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
