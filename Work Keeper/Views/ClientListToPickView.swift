import SwiftUI


struct ClientListToPickView: View {
    @State private var showNewClientView = false
    @StateObject var viewModel = ClientsListViewModel()
    @Environment(\.dismiss)
    private var dismiss

    @State private var clientForAddressPick: Client?
    @State private var isAddressPickerPresented = false
    
    var body: some View {
       
        
        ZStack {
            Color.custom(.mainBackground).ignoresSafeArea()
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
                            .foregroundStyle(.pitchBlack)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 30)
                
                HStack {
                    HStack {
                        Image("magnifyingGlass")
                            .resizable()
                            .frame(width: 21, height: 21)
                            .foregroundColor(Color.custom(.pitchBlack))
                            .padding(.leading, 20)
                        
                    TextField("Поиск клиента", text: $viewModel.searchText)
                       
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
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.custom(.searchFieldGray))
                            )
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
                .padding(.horizontal, 20)
                    
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
                                let addressesCount = client.addressesArray.count

                                // Если у клиента больше одного адреса — сначала попросим выбрать нужный
                                if addressesCount > 1 {
                                    clientForAddressPick = client
                                    isAddressPickerPresented = true
                                } else {
                                    // Иначе выбираем клиента сразу (адрес будет либо единственный, либо primary)
                                    viewModel.pickClient(client)
                                    dismiss()
                                }
                            }
                            .listRowBackground(Color.custom(.mainBackground))
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.inset)
                    .background(Color.custom(.mainBackground))
                }
                    
            }
            .frame(maxHeight: .infinity, alignment: .top)
//            .padding(.trailing, 15)
//            .padding(.leading, 20)
            .padding(.top, 20)

            // Address picker overlay
            if isAddressPickerPresented, let client = clientForAddressPick {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isAddressPickerPresented = false
                        }
                        clientForAddressPick = nil
                    }

                AddressPickOverlay(client: client) { address in
                    // Сохраняем выбор и закрываем экран выбора клиента
                    viewModel.pickClient(client, address: address)
                    isAddressPickerPresented = false
                    clientForAddressPick = nil
                    dismiss()
                } onPickNewAddress: {
                    // Выбираем клиента без адреса (адрес будет введён вручную на экране создания задания)
                    viewModel.pickClientWithNewAddress(client) // сбросит pickedAddress
                    isAddressPickerPresented = false
                    clientForAddressPick = nil
                    dismiss()
                } onCancel: {
                    isAddressPickerPresented = false
                    clientForAddressPick = nil
                }
                .transition(.scale.combined(with: .opacity))
                .padding(.horizontal, 16)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isAddressPickerPresented)
        
        
        .onAppear {
            viewModel.loadClients()
        }
        
    }
    
}

private struct AddressPickOverlay: View {

    var client: Client
    var onPick: (Address) -> Void
    var onPickNewAddress: () -> Void
    var onCancel: () -> Void
    

    private var addresses: [Address] { client.addressesArray }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Выберите адрес")
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .foregroundStyle(.pitchBlack)
                Spacer()
                Button("Закрыть") {
                    onCancel()
                }
                .font(.custom(SFPro.regular.rawValue, size: 15))
                .foregroundStyle(.pitchBlack)
            }

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(addresses, id: \.objectID) { address in
                        Button {
                            onPick(address)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(address.street?.name ?? "Улица не указана")
                                        .font(.custom(SFPro.regular.rawValue, size: 16))
                                        .foregroundStyle(.pitchBlack)

                                    Text(composeSubtitle(address))
                                        .font(.custom(SFPro.regular.rawValue, size: 13))
                                        .foregroundStyle(Color.custom(.taskTextGray))
                                }

                                Spacer()

                                if address.isPrimary {
                                    Image(systemName: "house.fill")
                                        .foregroundStyle(Color.custom(.highlightBlue))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.custom(.bckgFieldGray))
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button("Новый адрес +") {
                       onPickNewAddress()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                   
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.pitchBlack), lineWidth: 0.5)
                    )
                    
                }
            }
            .frame(maxHeight: 260)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.custom(.pureWhite))
                .shadow(radius: 10)
        )
    }

    private func composeSubtitle(_ address: Address) -> String {
        var parts: [String] = []

        if let house = address.house, !house.isEmpty {
            parts.append("д. \(house)")
        }
        if let apartment = address.apartment, !apartment.isEmpty {
            parts.append("\(address.roomType ?? "кв.") \(apartment)")
        }
        if let entrance = address.entrance, !entrance.isEmpty {
            parts.append("\(address.entranceType ?? "под.") \(entrance)")
        }
        if let floor = address.floor, !floor.isEmpty {
            parts.append("эт. \(floor)")
        }

        return parts.joined(separator: ", ")
    }
}

#Preview {
    ClientsListView()
}
