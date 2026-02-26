import SwiftUI

struct ClientsListView: View {
    @State private var showNewClientView = false
    @State private var showDeleteAlert = false
    @State private var showSortOrderMenu = false
    @State private var showAddClientNotification = false
    @State private var showDeleteClientNotification = false
    @State private var showEditClientNotification = false
    @State private var isSpinning = false
    @State private var removedClientsActive = false
    @State private var lastAddedClientName = ""
    @State private var lastDeletedClientName = ""
    @State private var lastEditedClientName = ""
    
    @StateObject private var viewModel = ClientsListViewModel()

    @State private var selectedClient: Client?
    @State private var clientToDelete: Client?
    @State private var clientToEdit: Client?
    @State private var client: Client?
   
    
    // MARK: - Sync Objects
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    
    private let headerOverlayHeight: CGFloat = 110
    
    private func refreshScreen() {
        viewModel.loadUserDefaultsAndSort()
        viewModel.loadRemovedClients()
    }
    var body: some View {
        
        NavigationStack {
            ZStack {
                // Always fill the screen so the top overlay has a stable layout container
                Color.custom(.mainBackground)
                    .ignoresSafeArea()

                if viewModel.clients.isEmpty {
                    Image(ImageResource(name: "noClientsBackground", bundle: .main))
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { hideKeyboard() }
                }

                VStack {
  
                    if viewModel.clients.isEmpty && viewModel.removedClients.isEmpty {
                        
                        EmptyListPlaceholderView(
                            line1: .init(
                                text: viewModel.searchText.isBlank ? "КЛИЕНТОВ" : "КЛИЕНТ",
                                color: Color.custom(.taskViewYellow),
                                font: .custom(Montserrat.black.rawValue, size: 38),
                                height: 27
                            ),
                            line2: .init(
                                text: viewModel.searchText.isBlank ? "ПОКА" : "НЕ",
                                color: Color.custom(.taskCompleteGreen),
                                font: .custom(Montserrat.bold.rawValue, size: 38),
                                height: 27
                            ),
                            line3Text: viewModel.searchText.isBlank ? "НЕТ" : "НАЙДЕН",
                            line3TextFont: .custom(Montserrat.regular.rawValue, size: 38),
                            line3Suffix: "...",
                            line3SuffixFont: .custom(Montserrat.black.rawValue, size: 38),
                            line3Color: Color.custom(.taskCanceledOrange),
                            line3Height: 27,
                            hintText: viewModel.searchText.isBlank ? "Создайте карточку клиента, нажав на \nиконку “+“ в правом верхнем углу экрана" : ""
                        )
                    } else if viewModel.clients.isEmpty && !viewModel.removedClients.isEmpty {
                        VStack(spacing: 18) {
                            HStack {
                                Text("Все клиенты удалены.\nСоздайте новых или восстановите\nранее удалённых ")
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(.pitchBlack)
                                Spacer()
                            }
                            ZStack {
                                NavigationLink {
                                    RemovedClientsView(onClose: {
                                        viewModel.loadUserDefaultsAndSort()
                                        viewModel.loadRemovedClients()
                                    })
                                } label: {
                                    HStack(spacing: 15) {
                                        Text("Удалённые клиенты")
                                            .font(.custom(Montserrat.bold.rawValue, size: 17))
                                            .foregroundStyle(.cancelButtonRed)

                                        Text("(\(viewModel.removedClients.count))")
                                            .font(.custom(Montserrat.bold.rawValue, size: 17))
                                        Spacer()
                                    }
                                    
                                    .frame(height: 15)
                                }
 
                            }
                            .listRowSeparator(.hidden)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 46)
                    } else {
                        
                        List {
                            if !viewModel.removedClients.isEmpty {
                                ZStack {
                                    NavigationLink {
                                        RemovedClientsView(onClose: {
                                            viewModel.loadUserDefaultsAndSort()
                                            viewModel.loadRemovedClients()
                                        })
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0)

                                    HStack(spacing: 15) {
                                        Image(systemName: "xmark.bin")
                                        Text("Удалённые клиенты")
                                            .font(.custom(Montserrat.regular.rawValue, size: 14))
                                            .foregroundStyle(.textTitleGray)

                                        Spacer()

                                        Text("\(viewModel.removedClients.count)")
                                            .font(.custom(Montserrat.bold.rawValue, size: 12))
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 15)
                                }
                                .listRowSeparator(.hidden)
                            }
                            ForEach(viewModel.clientsGroupedByFirstLetter, id: \.letter) { section in
                                Section(header:
                                    HStack {
                                        Rectangle()
                                            .frame(height: 1)
                                        Text(section.letter)
                                            .font(.custom(Montserrat.bold.rawValue, size: 15))
                                        Rectangle()
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, -8)
                                    .padding(.bottom, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 18)
                                    .background(Color.clear)
                                ) {
                                    ForEach(section.clients) { client in
                                        ClientRow(client: client, viewModel: viewModel)
                                            .padding(.vertical, 5)
                                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                                            .listRowSeparator(.hidden)
                                            .contentShape(Rectangle())
                                            .onTapGesture { selectedClient = client }
                                            .swipeActions(edge: .trailing) {
                                                Button {
                                                    clientToDelete = client
                                                    showDeleteAlert = true
                                                } label: {
                                                    Image("delete")
                                                    Text("Удалить")
                                                }
                                                .tint(Color.custom(.pureWhite))

                                                Button {
                                                    clientToEdit = client
                                                    // Edit uses the `.sheet(item: $clientToEdit, ...)` below
                                                } label: {
                                                    Image("edit")
                                                    Text("Редактировать")
                                                }
                                                .tint(Color.custom(.pureWhite))
                                            }
                                    }
                                }
                            }
                            .listRowBackground(Color.custom(.mainBackground))
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(PlainListStyle())
                        .safeAreaInset(edge: .top) {
                            // Reserve space for the custom top overlay so pinned section headers
                            // stop below it instead of sticking to the very top.
                            Color.clear
                                .frame(height: headerOverlayHeight)
                        }
                        .background(Color.custom(.mainBackground))
                        .navigationDestination(item: $selectedClient) { client in
                            ClientProfileView(client: client, onDismiss: { refreshScreen() })
                        }
                    }
                }
              

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            .overlay(alignment: .top) {
                VStack {
                    HStack {
                        Button(action: {
                            switch viewModel.sortSelection {
                            case .nameAZ:
                            
                                viewModel.sortSelection = .nameZA
                                viewModel.applySort(option: viewModel.sortSelection)
                            case .nameZA:
                                
                                viewModel.sortSelection = .nameAZ
                                viewModel.applySort(option: viewModel.sortSelection)
                            }
                        }) {
                            Image(viewModel.sortSelection == .nameAZ ? "sortAZ" : "sortZA" )
                                .resizable()
                                .frame(width: 30, height: 30)
                                
                                
                        }
//                        .padding(.leading, 3)
                        
                        Spacer()
                        
                        if !networkMonitor.isOnline {
                            HStack(alignment: .center ) {
                                
                                Text("Нет сети, работа оффлайн")
                                    .font(.custom(Montserrat.regular.rawValue, size: 11))
                                    .foregroundColor(.pitchBlack)
                                Image(systemName: "wifi.slash")
                                    .font(.system(size: 13))
                                    .foregroundColor(.pitchBlack)
                            }
                            .frame(height: 15)
                            
                            
                        } else {
                            
                            switch syncService.phase {
                            case .syncing:
                                HStack {
                                   
                                    Text("синхронизация")
                                        .font(.custom(Montserrat.regular.rawValue, size: 11))
                                    Image("sync")
                                        .resizable()
                                        .frame(width: 13.55, height: 15)
                                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isSpinning)
                                        .onAppear { isSpinning = true }
                                        .onDisappear { isSpinning = false }
                                }
                                
                                .frame(height: 15)
                                
                            case .success:
                                HStack {
                                   
                                    Text("синхронизировано")
                                        .font(.custom(Montserrat.regular.rawValue, size: 11))
                                    Image("syncCompleted")
                                        .resizable()
                                        .frame(width: 13.55, height: 15)
                                }
                                .frame(height: 15)
                                
                            case .failure:
                                HStack {
                                   
                                    Text("ошибка синхронизации")
                                        .font(.custom(Montserrat.regular.rawValue, size: 11))
                                    Image("syncError")
                                        .resizable()
                                        .frame(width: 13.55, height: 15)
                                }
                                .frame(height: 15)
                                
                            case .idle:
                                // Keep layout stable (optional). Remove this Spacer if you prefer the UI to collapse.
                                Spacer().frame(height: 15)
                            }
                        }
                        Spacer()
                        
                        Button(action: {
                            showNewClientView = true
                        }) {
                            Image("plusClients")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.pitchBlack)
                                .ifAvailableButtonStyleGlass()
                        }
                        
                    }
                    .padding(.horizontal, 36)
                    
                    HStack {
                        HStack {
                            Image("magnifyingGlass")
                                .resizable()
                                .frame(width: 21, height: 21)
                                .foregroundColor(Color.custom(.pitchBlack))
                                .padding(.leading, 20)
                            
                        TextField("Поиск клиента", text: $viewModel.searchText)
                                .font(.custom(Montserrat.regular.rawValue, size: 16))
                            .onSubmit {
                                hideKeyboard()
                            }
                            
                            Button(action:  {
                                viewModel.searchText = ""
                                
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                
                            }
                            .opacity(viewModel.searchText.isEmpty ? 0 : 1)
                            .padding(.trailing, 15)
                        }
                            .frame(height: 50)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                            .shadow(radius: 10, y: 6)
                           
                        if !viewModel.searchText.isEmpty {
                            Button(action:  {
                                viewModel.searchText = ""
                                hideKeyboard()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .foregroundStyle(Color.custom(.pitchBlack))
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 10)
                .padding(.bottom, 10)
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
                syncService.runManualSync(auth: auth, debug: true)
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
                syncService.runManualSync(auth: auth, debug: true)
            })
        }
        
        

        .onAppear {
           refreshScreen()
            
        }
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: clientToDelete) { client in
            Button(client.totalTasksCount > 0 ? "Удалить клиента и задания" : "Удалить клиента", role: .destructive) {
                let name = client.firstName ?? "имя не указано"
                lastDeletedClientName = name

                viewModel.softDelete(client)
                clientToDelete = nil
                viewModel.loadRemovedClients()
                viewModel.loadUserDefaultsAndSort()
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showDeleteClientNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showDeleteClientNotification = false
                    }
                }

                syncService.runManualSync(auth: auth, debug: true)
            }

            Button("Отмена", role: .cancel) {
                clientToDelete = nil
            }
        } message: { client in
            if client.totalTasksCount > 0 {
                Text(
                    "У клиента есть \(client.totalTasksCount) заданий. При удалении клиента будут удалены и все его задания (в любых статусах).\n\n" +
                    "Запланировано: \(client.scheduledTasksCount)\n" +
                    "Выполнено: \(client.completedTasksCount)\n" +
                    "Отменено: \(client.canceledTasksCount)"
                )
            } else {
                Text("Клиент \(client.firstName ?? "имя не указано") будет удалён")
            }
        }
        
    }
    
}



