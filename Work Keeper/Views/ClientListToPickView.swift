import SwiftUI


struct ClientListToPickView: View {
    @State private var showNewClientView = false
    @StateObject var viewModel = ClientsListViewModel()
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
       
        
        ZStack {
            Color(.white).ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
                
           
                    
                
                Spacer()
                    .frame(height: 10)
                
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
                            .fill(Color.custom(.searchFieldGray))
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
                            .onTapGesture {
                                viewModel.pickClient(client)
                                dismiss()
                            }
                           
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
            .padding(.top, 20)
        }
        
        
        .onAppear {
            viewModel.loadClients()
        }
        
    }
    
}


#Preview {
    ClientsListView()
}

