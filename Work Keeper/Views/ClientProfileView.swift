import SwiftUI



struct PrimaryAddressPickMenu: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
   
    @StateObject private var viewModel = ClientAddressesViewModel()
    @ObservedObject var client: Client
    @State private var addressToDelete: Address?
    @State private var showDeleteAddressDialog = false
    
    
    private var addresses: [Address] {
        client.addressesArray
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(addresses, id: \.objectID) { address in
                    Button(action: {
                        viewModel.setPrimary(address, for: client, in: context)
                        dismiss()
                    }) {
                        HStack(alignment: .top, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(address.street?.name ?? "Улица не указана")
                                    .font(.custom(SFPro.regular.rawValue, size: 18))
                                
                                HStack(spacing: 4) {
                                    Text(address.house ?? "")
                                    if let apartment = address.apartment, !apartment.isEmpty {
                                        Text("\(address.roomType ?? "кв.") \(apartment)")
                                    }
                                    if let entrance = address.entrance, !entrance.isEmpty {
                                        Text("\(address.entranceType ?? "под.") \(entrance)")
                                    }
                                    if let floor = address.floor, !floor.isEmpty {
                                        Text("эт. \(floor)")
                                    }
                                }
                                .font(.custom(SFPro.regular.rawValue, size: 14))
                                .foregroundColor(.custom(.taskTextGray))
                            }
                            
                            Spacer()
                            
                            if address.isPrimary {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.custom(.taskCompleteGreen))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            viewModel.setPrimary(address, for: client, in: context)
                            dismiss()
                        } label: {
                            Label("Сделать основным", systemImage: "checkmark.circle")
                        }

                        Button(role: .destructive) {
                            addressToDelete = address
                            showDeleteAddressDialog = true
                        } label: {
                            Label("Удалить адрес", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Основной адрес")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Удалить адрес?",
                isPresented: $showDeleteAddressDialog,
                titleVisibility: .visible
            ) {
                Button("Удалить", role: .destructive) {
                    if let addr = addressToDelete {
                        viewModel.softDelete(addr, for: client, in: context)
                        addressToDelete = nil
                    }
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                if let addr = addressToDelete {
                    Text("Адрес \(addr.street?.name ?? "Улица") \(addr.house ?? "") будет удалён")
                } else {
                    Text("Адрес будет удалён")
                }
            }
        }
    }
}


struct ClientProfileView: View {

    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
    
    @StateObject private var viewModel = ClientsListViewModel()
    @ObservedObject var client: Client
    @State private var clientToEdit: Client?
    @State private var clientToDelete: Client?
    @State private var selectedTaskForDetails: TaskEntity?
    @State private var didCopyPhoneNumber = false
    @State private var didCopyAddress = false
    @State private var isPrimaryAddressPickerPresented = false
    @State private var showSingleAddressMessage = false
    @State private var showNewAddressView = false
    @State private var showEditClientView = false
    @State private var showDeleteAlert = false
    @State private var lastDeletedClientName = ""
    @State private var lastEditedClientName = ""
    
    var body: some View {
        ScrollView {
        VStack {
            HStack {
                Spacer()
                
                Menu {
                    Button {
                        clientToEdit = client
                    } label: {
                        Label {
                            Text("Редактировать")
                                .font(.custom(Montserrat.regular.rawValue, size: 17))
                        } icon: {
                            Image("pen")
                        }
                    }
                    
                    Button {
                        showNewAddressView = true
                    } label: {
                        Label {
                            Text("Добавить адрес")
                                .font(.custom(Montserrat.regular.rawValue, size: 17))
                        } icon: {
                            Image("plusClients")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label {
                            Text("Удалить")
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .ifAvailableButtonStyleGlass()
                .frame(width: 35, height: 35)
                
                
            }

            .padding(.horizontal, 20)
            
            
            .confirmationDialog("Удалить клиента?", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) {
                    let clientName = client.firstName
                    lastDeletedClientName = clientName ?? "Неизвестный клиент"
                    viewModel.delete(client)
                    
                    syncService.runManualSync(auth: auth, debug: true)
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text("Клиент \(client.firstName ?? "без имени") будет удалён(на)")
            }
            
            
            
            HStack {
                Text(client.firstName ?? "имя не указано")
                    .font(.custom(Montserrat.bold.rawValue, size: 32))
                
                Text(client.lastName ?? "")
                    .font(.custom(Montserrat.bold.rawValue, size: 32))
            }
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 22)
            .padding(.top, 15)
            
            Button(action: {
                let text =
                client.phone
                UIPasteboard.general.string = text
                withAnimation { didCopyPhoneNumber = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 ) {
                    withAnimation { didCopyPhoneNumber = false
                    }
                }
                
            }) {
                //                            Text(client.phone?.formattedAsPhone() ?? "Телефон не указан")
                Text(client.phone ?? "Телефон не указан")
                    .font(.custom(Montserrat.regular.rawValue, size: 19))
                    .foregroundColor(.custom(.taskTextGray))
            }
            
            
            
            if !client.hasAddress {
                HStack {
                    Button(action: {
                        
                        
                    }) {
                        Image("home")
                            .opacity(0.5)
                    }
                    
                    Spacer()
                    
                    Text("Клиент не давал адрес")
                        .frame(height: 48)
                        .font(.custom(Montserrat.regular.rawValue, size: 24))
                    
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 9)
                
                
            } else {
                HStack {
                    
                    Button(action: {
                        if client.addressesArray.count > 1 {
                            isPrimaryAddressPickerPresented = true
                        } else if client.addressesArray.count == 1 {
                            withAnimation { showSingleAddressMessage = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ) {
                                withAnimation { showSingleAddressMessage = false }
                            }
                            
                        }
                    }) {
                        Image("home")
                    }
                    Spacer()
                    
                    Button(action: {
                        let text =
                        client.formattedAddress
                        UIPasteboard.general.string = text
                        withAnimation { didCopyAddress = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 ) {
                            withAnimation { didCopyAddress = false
                            }
                        }
                        
                    }) {
                        HStack {
                            Text(client.primaryAddress?.street?.name ?? "Адрес не указан")
                            +
                            Text(" \(client.primaryAddress?.house ?? "")")
                        }
                        .frame(height: 48)
                        .font(.custom(Montserrat.regular.rawValue, size: 24))
                        .lineLimit(2, reservesSpace: false)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 17)
                }
                .padding(.horizontal, 30)
                
                
                
                
                if client.primaryAddress?.isPrivateHouse == false {
                    HStack { //not private house
                        Text("\(client.primaryAddress?.roomType ?? "кв.") \(client.apartmentNumber)")
                            .font(.custom(Montserrat.regular.rawValue, size: 20))
                        
                        Spacer()
                        
                        Text("\(client.primaryAddress?.entranceType ?? "под.") \(client.entranceNumber)")
                            .font(.custom(Montserrat.regular.rawValue, size: 20))
                        
                        Spacer()
                        
                        Text("эт. \(client.floorNumber)")
                            .font(.custom(Montserrat.regular.rawValue, size: 20))
                    }
                    .padding(.horizontal, 80)
                } else {
                    Text("Только дом")
                        .font(.custom(SFPro.italic.rawValue, size: 20))
                        .foregroundColor(.custom(.taskTextGray))
                        .padding(.top, -10)
                }
            }
            
            Text(client.comment ?? "")
                .font(.custom(Montserrat.italic.rawValue, size: 18))
                .foregroundColor(.custom(.taskTextGray))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 15)
                .padding(.top, 15)
            
            Spacer()
                .frame(height: 35)
            
            Text("Доход от клиента")
                .font(.custom(Montserrat.regular.rawValue, size: 20))
                .foregroundColor(.custom(.taskTextGray))
            
            Spacer()
                .frame(height: 15)
            
            Text(client.totalIncome.formattedCurrency())
                .font(.custom(Montserrat.bold.rawValue, size: 32))
            
            
            Spacer()
                .frame(height: 18)
            
            Rectangle()
                .frame(height: 0.5)
                .padding(.horizontal, 30)
                .foregroundColor(.custom(.separatorLineGray))
            
            HStack {
                Text("Всего заданий")
                    .font(.custom(Montserrat.regular.rawValue, size: 20))
                
                
                Text("\(client.totalTasksCount)")
                    .font(.custom(SFPro.bold.rawValue, size: 24))
                
            }
            
            Spacer()
                .frame(height: 19)
            
            HStack {
                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.custom(.taskCompleteGreen))
                Text(" - \(client.completedTasksCount)")
                Spacer()
                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.custom(.taskViewYellow))
                Text(" - \(client.scheduledTasksCount)")
                Spacer()
                Rectangle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.custom(.taskCanceledOrange))
                Text(" - \(client.canceledTasksCount)")
            }
            .padding(.horizontal, 58)
            
            Spacer()
                .frame(height: 31)
            
            // MARK: - Tasks list for this client
            let defaultDate = Date()
            
            let clientTasks = (client.tasks as? Set<TaskEntity>)?.sorted(by: { ($0.scheduledAt ?? defaultDate) > ($1.scheduledAt ?? defaultDate) }) ?? []
            
            let actualTasks = clientTasks.filter { $0.deletedAt == nil }
            
            if actualTasks.isEmpty {
                VStack(spacing: 12) {
                    Image("noTasksPlaceholder")
                        .padding(.leading, 50)
                    Text("У этого клиента пока нет заданий")
                        .font(.custom(SFPro.regular.rawValue, size: 22))
                        .foregroundColor(.custom(.taskTextGray))
                }
                .padding(.top, 8)
            } else {
                List {
                    ForEach(actualTasks) { task in
                        ClientTaskCell(task: task)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTaskForDetails = task
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            
            Spacer()
            
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedTaskForDetails) { task in
            TaskView(task: task)
        }
    }
            
            .overlay(alignment: .center) {
                if didCopyPhoneNumber {
                    Text("Номер клиента скопирован")
                        .font(.custom(SFPro.regular.rawValue, size: 18))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 20)
                
                }
            }
            
            .overlay(alignment: .center) {
                if showSingleAddressMessage {
                    Text("Это единственный адрес клиента")
                        .font(.custom(SFPro.regular.rawValue, size: 18))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 20)
                
                }
            }
                
            .overlay(alignment: .center) {
                if didCopyAddress {
                    Text("Адрес клиента скопирован")
                        .font(.custom(SFPro.regular.rawValue, size: 18))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 20)
                        
                
                }
            }
            .sheet(isPresented: $isPrimaryAddressPickerPresented) {
                PrimaryAddressPickMenu(client: client)
            }
            
            .sheet(isPresented: $showNewAddressView, onDismiss: {
                syncService.runManualSync(auth: auth, debug: true)
            }) {
                AddAddressView(clientsVM: viewModel, client: client)
            }
            
            .sheet(item: $clientToEdit, onDismiss: {
            }) { client in
                EditClientView(viewModel: EditClientViewModel(client: client),
                               onEdit: { editedName in
                    lastEditedClientName = editedName
                 
                    syncService.runManualSync(auth: auth, debug: true)
                })
            }
            
    }
}
