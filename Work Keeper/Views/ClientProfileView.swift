import SwiftUI

struct PrimaryAddressPickMenu: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var client: Client
    
    private var addresses: [Address] {
        client.addressesArray
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(addresses, id: \.objectID) { address in
                    Button(action: {
                        setPrimary(address)
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
        }
    }
    
    private func setPrimary(_ address: Address) {
        if let all = client.address as? Set<Address> {
            for addr in all {
                addr.isPrimary = (addr == address)
            }
        } else {
            address.isPrimary = true
        }
        
        do {
            try context.save()
            context.refresh(client, mergeChanges: true) //Обновление данных во всех ObservedObjects, связанных с client
           
        } catch {
            print("[PrimaryAddressPickMenu] Failed to save primary address:", error)
        }
        
        dismiss()
    }
}


struct ClientProfileView: View {

    @ObservedObject var viewModel = ClientsListViewModel()
    @ObservedObject var client: Client
    @State private var selectedTaskForDetails: TaskEntity?
    @State private var didCopyPhoneNumber = false
    @State private var didCopyAddress = false
    @State private var isPrimaryAddressPickerPresented = false
    @State private var showSingleAddressMessage = false
    
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    
                    VStack{
                        Text(client.firstName ?? "имя не указано")
                            .font(.custom(Montserrat.bold.rawValue, size: 32))
                        
                        
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
                    }
                    Spacer()
                    
                 
                }
                .padding(.horizontal, 22)
                
                Spacer()
                    .frame(height: 9)
                
                if !client.hasAddress {
                    HStack {
                        Button(action: {
                            if client.addressesArray.count > 1 {
                                isPrimaryAddressPickerPresented = true
                            } else if client.addressesArray.count == 1 {
                                showSingleAddressMessage = true
                            }
                        }) {
                            Image("home")
                        }
                        
                        Spacer()
                        
                        Text("Клиент не давал адрес")
                            .frame(height: 48)
                            .font(.custom(SFPro.regular.rawValue, size: 24))
                           
                            .frame(width: 300, alignment: .center)
                            .multilineTextAlignment(.center)
                            
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                        .frame(height: 17)
                    
                 
                    
            } else {
                HStack {
                    
                    Button(action: {
                        if client.addressesArray.count > 1 {
                            isPrimaryAddressPickerPresented = true
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
                        
                        Text("\(client.primaryAddress?.house ?? "")")
                    }
                            .frame(height: 48)
                            .font(.custom(Montserrat.regular.rawValue, size: 24))
                            .lineLimit(2, reservesSpace: false)
                            .frame(width: 300, alignment: .center)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 17)
                
                
                if client.primaryAddress?.isPrivateHouse == false {
                    HStack { //not private house
                        Text("\(client.addressesArray.first?.roomType ?? "кв.") \(client.apartmentNumber)")
                            .font(.custom(Montserrat.regular.rawValue, size: 20))
                        
                        Spacer()
                        
                        Text("\(client.addressesArray.first?.entranceType ?? "под.") \(client.entranceNumber)")
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
    }
}
