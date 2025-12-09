import SwiftUI

struct ClientProfileView: View {

    @ObservedObject var viewModel = ClientsListViewModel()
    var client: Client
    @State private var selectedTaskForDetails: TaskEntity?
    @State private var didCopyPhoneNumber = false
    @State private var didCopyAddress = false
    
        var body: some View {
            
          

            VStack {
                
                HStack {
                    Spacer()
                    
                    VStack{
                        Text(client.firstName ?? "имя не указано")
                            .font(.custom(SFPro.bold.rawValue, size: 32))
                        
                        
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
                                .font(.custom(SFPro.regular.rawValue, size: 19))
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
                        Image("remote")
                        
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
                    Image("home")
                    
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
                        Text(client.formattedAddress)
                            .frame(height: 48)
                            .font(.custom(SFPro.regular.rawValue, size: 24))
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
                            .font(.custom(SFPro.regular.rawValue, size: 20))
                        
                        Spacer()
                        
                        Text("\(client.addressesArray.first?.entranceType ?? "под.") \(client.entranceNumber)")
                            .font(.custom(SFPro.regular.rawValue, size: 20))
                        
                        Spacer()
                        
                        Text("эт. \(client.floorNumber)")
                            .font(.custom(SFPro.regular.rawValue, size: 20))
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
                    .font(.custom(SFPro.regular.rawValue, size: 20))
                    .foregroundColor(.custom(.taskTextGray))
                
                Spacer()
                    .frame(height: 15)
                
                Text(client.totalIncome.formattedCurrency())
                    .font(.custom(SFPro.bold.rawValue, size: 32))
                
                
                Spacer()
                    .frame(height: 18)
                
                Rectangle()
                    .frame(height: 0.5)
                    .padding(.horizontal, 30)
                    .foregroundColor(.custom(.separatorLineGray))
                
                HStack {
                    Text("Всего заданий")
                        .font(.custom(SFPro.regular.rawValue, size: 20))
                        
                    
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

                if clientTasks.isEmpty {
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
                        ForEach(clientTasks) { task in
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
            
    }
}




