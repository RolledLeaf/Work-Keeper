import SwiftUI


struct ClientsListView: View {
    @State private var showNewClientView = false
    @State private var showDeleteAlert = false
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClient: Client?
    @State private var clientToDelete: Client?
    @State private var client: Client?
    
    var body: some View {
        
        NavigationStack {
        ZStack {
        
            Color(.white).ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                HStack {
                    Button(action: {
                        //action
                    }) {
                        Image("sortAZ")
                            .resizable()
                            .frame(width: 31, height: 22)
                    }
                    .padding(.leading, 3)
                    
                    
                    Spacer()
                    
                    Button(action: {
                        showNewClientView = true
                    }) {
                        Image("addClientButton")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .padding(.trailing, 5)
                }
                
                TextField("Поиск клиента", text: .constant(""))
                    .padding(9)
                    .padding(.leading, 25)
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .background(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            Spacer()
                        })
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.custom(.searchFieldGray) ?? .searchFieldGray)
                    )
                    .padding(.leading, 1)
                    .padding(.trailing, 1)
                if viewModel.clients.isEmpty {
                    
                    Spacer()
                        .frame(height: 165)
                    
                    Image("noClientsPlaceholder")
                        .resizable()
                        .frame(width: 276, height: 268)
                    
                    Text("Клиентов пока нет")
                } else {
                   
                        List(viewModel.clients) { client in
                            ClientRow(client: client)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedClient = client
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(action: {
                                        showDeleteAlert = true
                                        clientToDelete = client
                                    }) {
                                        Image("delete")
                                        Text("Удалить")
                                    }
                                    .tint(Color.custom(.deleteButtonRed))

                                    Button(action: {
                                        
                                    }) {
                                        Image("edit")
                                        Text("Редактировать")
                                    }
                                    .tint(Color.custom(.editButtonGray))
                                }
                            
                        }
                        .listRowSeparator(.hidden)
                        .listStyle(PlainListStyle())
                        .padding(.leading, -20)
                        .padding(.trailing, -20)
                        
                        .navigationDestination(item: $selectedClient) { client in
                            ClientProfileView(client: client)
                        }
                    }
                }
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.trailing, 15)
            .padding(.leading, 20)
        }
        .sheet(isPresented: $showNewClientView, onDismiss: {
            viewModel.loadClients()
            print("clients list reloaded (onDismiss)")
        }) {
            NewClientView()
        }
        
        .onAppear {
            viewModel.loadClients()
            print("clients list reloaded")
        }
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: clientToDelete) {
            client in
            Button("Да", role: .destructive) {
                viewModel.delete(client)
            }
            Button("Нет", role: .cancel) {}
        } message: { client in
            Text("Клиент \(client.firstName ?? "имя не указано") будет удалён")
        }
        
    }
    
}


#Preview {
    ClientsListView()
}

