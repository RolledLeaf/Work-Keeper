import SwiftUI


let clients: [Client] = [clientBoris, clientDiana, clientJulia, clientPetr]
    

struct ClientsListView: View {
    @State private var showNewClientView = false
    
    var body: some View {
      
        
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
                if clients.isEmpty {
                    
                    Spacer()
                        .frame(height: 165)
                    
                    Image("noClientsPlaceholder")
                        .resizable()
                        .frame(width: 276, height: 268)
                    
                    Text("Клиентов пока нет")
                } else {
                    List(clients) { client in
                        ClientRow(client: client)
                            .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                    .listStyle(PlainListStyle())
                    .padding(.leading, -20)
                    .padding(.trailing, -20)
                }
                    
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.trailing, 15)
            .padding(.leading, 20)
        }
        .sheet(isPresented: $showNewClientView) {
            NewClientView()
        }
        
    }
    
}


#Preview {
    ClientsListView()
}

