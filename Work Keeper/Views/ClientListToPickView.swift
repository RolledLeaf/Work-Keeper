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
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        
                        Text("Отмена")
                            .font(.custom(SFPro.regular.rawValue, size: 15))
                    }
                    
                   
                    .tint(.black)
                    
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 30)
                
                HStack {
                    TextField("Поиск клиента", text: $viewModel.searchText)
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
                    
                    if !viewModel.searchText.isEmpty {
                        
                        Button(action:  {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.black)
                        }
                    }
                }
                    
                if viewModel.clients.isEmpty {
                    
                    VStack {
                        
                        Image("noClientsPlaceholder")
                            .resizable()
                            .frame(width: 276, height: 268)
                        
                        Text("Клиентов пока нет")
                    }
                    .padding(.top, 50)
                        
                        
                } else {
                    List(viewModel.clients) { client in
                        ClientRow(client: client, viewModel: viewModel)
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

