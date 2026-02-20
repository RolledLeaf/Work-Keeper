import SwiftUI

private enum RemovedClientsFormatters {
    static let deletedAt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()
}

struct RemovedClientsView: View {
    @State private var showNewClientView = false
    @State private var showDeleteAlert = false
    @State private var showSortOrderMenu = false
    @State private var showAddClientNotification = false
    @State private var showDeleteClientNotification = false
    @State private var showEditClientNotification = false
    @State private var isSpinning = false
    @State private var lastAddedClientName = ""
    @State private var lastDeletedClientName = ""
    @State private var lastEditedClientName = ""
    @State private var showPurgeAllDialog = false
    
    @StateObject private var viewModel = ClientsListViewModel()

    @State private var selectedClient: Client?
    @State private var clientToDelete: Client?
    @State private var clientToRestore: Client?
    @State private var client: Client?
    
     let onClose: (() -> Void)?
   
    
    // MARK: - Sync Objects
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    
    private let headerOverlayHeight: CGFloat = 110
    var body: some View {
        
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
  
                   
                    
                    if viewModel.removedClients.isEmpty {
                        
                        EmptyListPlaceholderView(
                            line1: .init(
                                text: viewModel.searchText.isBlank ? "УДАЛЁННЫХ" : "КЛИЕНТ",
                                color: Color.custom(.taskViewYellow),
                                font: .custom(Montserrat.black.rawValue, size: 38),
                                height: 27
                            ),
                            line2: .init(
                                text: viewModel.searchText.isBlank ? "КЛИЕНТОВ" : "НЕ",
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
                            hintText: viewModel.searchText.isBlank ? "" : ""
                        )
                        
//                        Spacer()
                    } else {
                        
                        List {
                            HStack {
                                Spacer()
                                Text("Удалённые клиенты")
                                    .font(.custom(Montserrat.bold.rawValue, size: 15))
                                    .foregroundStyle(.pitchBlack)
                                Spacer()
                            }
                            ForEach(viewModel.removedClientsSortedByDeletedAt) { client in
                                ZStack(alignment: .topTrailing) {
                                    ClientRow(client: client, viewModel: viewModel)

                                    if let deletedAt = client.deletedAt {
                                        Text(RemovedClientsFormatters.deletedAt.string(from: deletedAt))
                                            .font(.custom(Montserrat.regular.rawValue, size: 11))
                                            .foregroundStyle(.textTitleGray)
                                            .padding(.top, 8)
                                            .padding(.trailing, 10)
                                    }
                                }
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
                                        clientToRestore = client
                                        viewModel.restore(client)
                                    } label: {
                                        Image("edit")
                                        Text("Восстановить")
                                    }
                                    .tint(Color.custom(.pureWhite))
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
                            ClientProfileView(client: client)
                        }
                    }
                }
              

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            .overlay(alignment: .top) {
                VStack {
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
            
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewModel.removedClients.isEmpty {
                    Button {
                        showPurgeAllDialog = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.custom(.pitchBlack))
                    }
                }
            }
        }
        .confirmationDialog(
            "Удалить всех удалённых клиентов?",
            isPresented: $showPurgeAllDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить навсегда", role: .destructive) {
                viewModel.purgeAllRemovedClients()
                syncService.runManualSync(auth: auth, debug: true)
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Это действие удалит \(viewModel.removedClients.count) клиентов навсегда.")
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
 
        .onAppear {
            viewModel.loadRemovedClients()
            
        }
        
        .onDisappear { onClose?() }
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: clientToDelete) { client in
            Button(client.totalTasksCount > 0 ? "Удалить клиента и задания" : "Удалить клиента", role: .destructive) {
                let name = client.firstName ?? "имя не указано"
                lastDeletedClientName = name
                viewModel.delete(client)
                clientToDelete = nil

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
