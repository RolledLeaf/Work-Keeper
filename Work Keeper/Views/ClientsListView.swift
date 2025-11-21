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
    @State private var showEditClientView = false
    @State private var showAddClientNotification = false
    @State private var showDeleteClientNotification = false
    @State private var showEditClientNotification = false
    @State private var lastAddedClientName = ""
    @State private var lastDeletedClientName = ""
    @State private var lastEditedClientName = ""
    
    @StateObject private var viewModel = ClientsListViewModel()

    @State private var selectedClient: Client?
    @State private var clientToDelete: Client?
    @State private var clientToEdit: Client?
    @State private var client: Client?
    
    

    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                Color.custom(.mainBackground).ignoresSafeArea()
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
                                .foregroundStyle(.pitchBlack)
                        }
                        .padding(.leading, 3)
                        
                        
                        Spacer()
                        
                        Button(action: {
                            showNewClientView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 30, weight: .regular))
                                .foregroundStyle(.pitchBlack)
                                .padding(.trailing, 5)
                                .ifAvailableButtonStyleGlass()
                        }
                        
                    }
                    
                    .padding(.horizontal, 10)
                    
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
                            }
                            
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    if viewModel.clients.isEmpty {
                        
                        VStack {
                            
                            Image("noClientsPlaceholder")
                                .resizable()
                                .frame(width: 276, height: 268)
                            
                            Text("Клиентов пока нет")
                        }
                        .padding(.top, 50)
                        
                        Spacer()
                    } else {
                        
                        List(viewModel.clients) { client in
                            ClientRow(client: client, viewModel: viewModel)
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
                                        clientToEdit = client
                                        showEditClientView = true
                                    }) {
                                        Image("edit")
                                        Text("Редактировать")
                                    }
                                    .tint(Color.custom(.editButtonGray))
                                }
                                .listRowBackground(Color.custom(.mainBackground))
                                .listRowSeparator(.hidden)
                                
                            
                        }
                        .listStyle(.inset)
                        .background(Color.custom(.mainBackground))
                        
                        .navigationDestination(item: $selectedClient) { client in
                            ClientProfileView(client: client)
                        }
                    }
                }
                
            }
            
        }
        
        
        .overlay(alignment: .center) {
            Group {
                if showAddClientNotification {
                    AddClientConfirmationView(name: $lastAddedClientName)
                        .transition(.offset(y: 40).combined(with: .opacity))
                } else if showEditClientNotification {
                        EditClientConfirmationView(name: $lastEditedClientName)
                        .transition(.offset(y: 40).combined(with: .opacity))
                    } else if showDeleteClientNotification {
                            DeleteClientConfirmationView(name: $lastDeletedClientName)
                            .transition(.offset(y: 40).combined(with: .opacity))
                        }
                    }
                }
       
        
        .sheet(isPresented: $showNewClientView, onDismiss: {
            viewModel.loadUserDefaultsAndSort()
            print("clients list reloaded (onDismiss)")
        }) {
            NewClientView(onCreation: { name in
                lastAddedClientName = name
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showAddClientNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showAddClientNotification = false
                    }
                }
                viewModel.loadUserDefaultsAndSort()
            })
        }
        
        .sheet(item: $clientToEdit, onDismiss: {
            viewModel.loadUserDefaultsAndSort()
        }) { client in
            EditClientView(viewModel: EditClientViewModel(client: client),
                           onEdit: { editedName in
                lastEditedClientName = editedName
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showEditClientNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showEditClientNotification = false
                    }
                }
            })
        }
        
        .sheet(isPresented: $showSortOrderMenu) {
            SortPopoverView(selection: $viewModel.sortSelection) { chosen in
                viewModel.applySort(option: chosen)
                       }
                   }

        .onAppear {
            viewModel.loadUserDefaultsAndSort()
            
        }
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: clientToDelete) {
            client in
            Button("Да", role: .destructive) {
                
                let name = client.firstName ?? "имя не указано"
                lastDeletedClientName = name
                viewModel.delete(client)
                
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showDeleteClientNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showDeleteClientNotification = false
                    }
                }
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

