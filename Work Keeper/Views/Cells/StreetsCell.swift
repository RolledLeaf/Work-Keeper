import SwiftUI

struct StreetRow: View {
    @State private var showEditStreetView = false
    @State private var showDeleteStreetAlert = false
  
    @State private var streetForEdit: Street?
    @State private var lastDeletedStreet = ""
    @State private var lastEditedStreet = ""
    
    @ObservedObject var viewModel: StreetListViewModel
    // MARK: - Sync Objects
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
    
    let street: Street
    let isFirst: Bool
    let isLast: Bool
    
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
                
                if !isLast {
                    Rectangle()
                      .frame(height: 1)
                      .padding(.horizontal, 15)
                      .foregroundColor(.custom(.separatorLineGray))
                }
                    
            }
        }
        
      .listRowInsets(EdgeInsets())
        .cornerRadius(10,corners: isFirst ? [.topLeft, .topRight] : isLast ? [.bottomLeft, .bottomRight] : [])

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
                syncService.runManualSync(auth: auth, debug: true)
           
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Улица \(street.name ?? "без названия") будет удалена")
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
                syncService.runManualSync(auth: auth, debug: true)
                    
            }, viewModel: viewModel, street: street)
        }
    }
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
