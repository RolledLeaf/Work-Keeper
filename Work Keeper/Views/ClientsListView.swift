import SwiftUI


struct SortPopoverView: View {
    
    @Binding var selection: SortOption
    @Environment(\.dismiss) private var dismiss
    
    var onApply: ((SortOption) -> Void)?
    
    var body: some View {
          NavigationStack {
              VStack(spacing: 16) {
                  // drag indicator
                  Capsule()
                      .fill(Color(.systemGray5))
                      .frame(width: 56, height: 6)
                      .padding(.top, 6)

                  // Title
                  Text("Упорядочить")
                      .font(.system(size: 28, weight: .bold))
                      .padding(.top, 4)

                  // Card container with list-like rows
                  VStack(spacing: 0) {
                      ForEach(SortOption.allCases) { option in
                          Button(action: {
                              // select item
                              withAnimation(.easeInOut) {
                                  selection = option
                              }
                          }) {
                              HStack {
                                  // label
                                  Text(option.rawValue)
                                      .font(.system(size: 20))
                                      .foregroundColor(.primary)
                                  Spacer()
                                  // radio visual
                                  RadioCircle(isSelected: selection == option)
                              }
                              .contentShape(Rectangle())
                              .padding(.vertical, 18)
                              .padding(.horizontal, 16)
                          }
                          .buttonStyle(.plain)

                          // divider except after last
                          if option != SortOption.allCases.last {
                              Divider()
                                  .padding(.leading, 16)
                          }
                      }
                  }
                  .background(
                      RoundedRectangle(cornerRadius: 12)
                          .fill(Color(.systemGray6))
                  )
                  .padding(.horizontal, 16)

                  Spacer(minLength: 10)
              }
              .padding(.bottom, 12)
              .toolbar {
                  ToolbarItem(placement: .confirmationAction) {
                      Button("Готово") {
                          onApply?(selection)
                          dismiss()
                      }
                      .font(.system(size: 17, weight: .semibold))
                  }
              }
          }
          .presentationDetents([.medium])             // полумодал
          .presentationCornerRadius(20)
          .presentationDragIndicator(.hidden)         // мы сами рисуем
      }
  }

  // small radio circle view
  struct RadioCircle: View {
      let isSelected: Bool
      var body: some View {
          ZStack {
              Circle()
                  .stroke(lineWidth: 2)
                  .frame(width: 26, height: 26)
                  .foregroundColor(isSelected ? Color.purple : Color.gray.opacity(0.6))
              if isSelected {
                  Circle()
                      .frame(width: 12, height: 12)
                      .foregroundColor(Color.purple)
              }
          }
          .animation(.easeInOut(duration: 0.15), value: isSelected)
      }
  }

struct ClientsListView: View {
    @State private var showNewClientView = false
    @State private var showDeleteAlert = false
    @State private var showSortOrderMenu = false
    @StateObject private var viewModel = ClientsListViewModel()
    @State private var selectedClient: Client?
    @State private var clientToDelete: Client?
    @State private var client: Client?
    @State private var sortSelection: SortOption = .nameAZ
    
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
                        showSortOrderMenu = true
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
        .sheet(isPresented: $showSortOrderMenu) {
            SortPopoverView(selection: $sortSelection) { chosen in
                viewModel.applySort(option: chosen)
                       }
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

