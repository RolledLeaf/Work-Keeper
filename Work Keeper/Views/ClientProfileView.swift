import SwiftUI

struct ClientProfileView: View {

    @ObservedObject var viewModel = ClientsListViewModel()
    var client: Client
    @State private var selectedTaskForDetails: Task?
    
        var body: some View {
            
            let initials = ((client.firstName?.prefix(1) ?? "") + (client.lastName?.prefix(1) ?? "")) // boiler code

            VStack {
                
                HStack {
                    Spacer()
                    
                    VStack{
                        Text(client.firstName ?? "имя не указано")
                            .font(.custom(SFPro.bold.rawValue, size: 32))
                        
                        Text(client.phone?.formattedAsPhone() ?? "Телефон не указан")
                            .font(.custom(SFPro.regular.rawValue, size: 16))
                            .foregroundColor(.custom(.taskTextGray))
                    }
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 25, height: 7)
                            .foregroundColor(.gray)
                            .offset(y: -11)
                    }
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
                    
                    Text(client.formattedAddress)
                        .frame(height: 48)
                        .font(.custom(SFPro.regular.rawValue, size: 24))
                        .lineLimit(2, reservesSpace: false)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                    Spacer()
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
                    Text("Частный дом")
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
                    
                    Text("✅ - \(client.completedTasksCount)")
                    Spacer()
                    Text("🔄 - \(client.scheduledTasksCount)")
                    Spacer()
                    Text("❌ - \(client.canceledTasksCount)")
                }
                .padding(.horizontal, 58)
           
                Spacer()
                    .frame(height: 31)
                
                // MARK: - Tasks list for this client
                let defaultDate = Date()
                
                let clientTasks = (client.tasks as? Set<Task>)?.sorted(by: { ($0.scheduledAt ?? defaultDate) > ($1.scheduledAt ?? defaultDate) }) ?? []

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
    }
}




