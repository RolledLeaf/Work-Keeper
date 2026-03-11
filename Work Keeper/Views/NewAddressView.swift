import SwiftUI

struct AddAddressView: View {
    @StateObject var clientsVM: ClientsListViewModel
    let client: Client
    
    @StateObject private var streetListViewModel = StreetListViewModel()
    
    private let maxBuildingCharactersCount: Int = 9
    private let maxStreetCharactersCount: Int = 49
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 4
    private let maxFloorCharacters: Int = 4
    
    @State private var streetName: String = ""
    @State private var building: String = ""
    @State private var apartment: String = ""
    @State private var entrance: String = ""
    @State private var floor: String = ""
    @State private var addressNote: String = ""
    @State private var isPrivateHouse: Bool = false
    @State private var makePrimary: Bool = false
    
    @State private var roomType: String = "кв"
    @State private var entranceType: String = "под"
    
    private let roomTypes = ["кв", "оф", "каб"]
    private let entranceTypes = ["под", "вход"]
    
    @State private var showStreetsView = false
    @State private var StreetCharactersTextOpacity: Double = 0
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) var dismiss
    
    enum Field {
        case house
        case apartment
        case entrance
        case floor
    }
    
    
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                
                VStack {
                    Text("Новый адрес для клиента")
                        .foregroundColor(Color.custom(.mainBlack))
                        .font(.custom(Montserrat.bold.rawValue, size: 20))
                    HStack {
                        Text("\(client.firstName ?? "нет имени")").textCase(.uppercase)
                            .foregroundColor(Color.custom(.mainBlack))
                            .font(.custom(Montserrat.regular.rawValue, size: 19))
                        Text("\(client.lastName ?? "нет фамилии")").textCase(.uppercase)
                            .foregroundColor(Color.custom(.mainBlack))
                            .font(.custom(Montserrat.regular.rawValue, size: 19))
                    }
                }
            VStack {
                //address section
                HStack {
                    Text("Улица")
                        .foregroundColor(Color.custom(.textTitleGray))
                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                        .background(Color.clear)
                    
                    Spacer()
                }
                .padding(.leading, 36)
                .frame(height: 12)
                
                HStack {
                    HStack(spacing: 6) {
                        TextEditor(text: $streetName)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .frame(height: 40, alignment: .center)
                            .multilineTextAlignment(.leading)
                        //                        .disabled(viewModel.remoteEditingBlock)
                            .scrollContentBackground(.hidden)
                            .onChange(of: streetName) { _, newValue in
                                if newValue.count > maxStreetCharactersCount {
                                    streetName = String(newValue.prefix(maxStreetCharactersCount))
                                }
                                if streetName.count >= maxStreetCharactersCount {
                                    StreetCharactersTextOpacity = 1
                                } else {
                                    StreetCharactersTextOpacity = 0
                                }
                            }
                            .offset(y: 2)
                        Spacer()
                        Button(action: {
                            showStreetsView = true
                        }) {
                            Image("chevronRight")
                        }
                        .tint(Color.custom(.pitchBlack))
                    }
                    .frame(height: 40)
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.custom(.pureWhite))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 20)
                
                
                
                //Street section end
                
                HStack {
                    
                    HStack(spacing: 6) {
                        Spacer()
                        Text("дом")
                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                            .foregroundStyle(Color.custom(.textTitleGray))
                        Image("deviderVertical")
                        TextField("", text: $building)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .house)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .apartment
                            }
                            .onChange(of: building) { newValue in
                                if newValue.count > maxBuildingCharactersCount {
                                    building = String(newValue.prefix(maxBuildingCharactersCount))
                                }
                            }
                        Spacer()
                    }
                    
                    .cornerRadius(30)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill( Color.custom(.pureWhite))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Spacer()
                        Menu {
                            ForEach(roomTypes, id: \.self) { type in
                                Button(type) {
                                    roomType = type
                                }
                            }
                        } label: {
                            Text(roomType)
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .foregroundColor(Color.custom(.pitchBlack))
                                .frame(width: 25)
                        }
                        .disabled(isPrivateHouse == true)
                        
                        Image("deviderVertical")
                        
                        TextField("", text: $apartment)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .apartment)
                            .submitLabel(.next)
                            .disabled(isPrivateHouse == true)
                            .onSubmit {
                                focusedField = .entrance
                            }
                            .disabled(isPrivateHouse == true)
                            .onChange(of: apartment) { newValue in
                                if newValue.count > maxApartmentCharactersCount {
                                    apartment = String(newValue.prefix(maxApartmentCharactersCount))
                                }
                            }
                        Spacer()
                    }
                    
                    .cornerRadius(30)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.custom(isPrivateHouse == true ? .inactiveFiledGray : .pureWhite ))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Spacer()
                        Menu {
                            ForEach(entranceTypes, id: \.self) { type in
                                Button(type) {
                                    entranceType = type
                                }
                            }
                        } label: {
                            Text(entranceType)
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .frame(width: 32)
                        }
                        .disabled(isPrivateHouse == true)
                        
                        Image("deviderVertical")
                        
                        TextField("", text: $entrance)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .frame(width: 32)
                            .multilineTextAlignment(.center)
                            .focused($focusedField, equals: .entrance)
                            .submitLabel(.next)
                            .disabled(isPrivateHouse == true)
                            .onSubmit {
                                focusedField = .floor
                            }
                            .onChange(of: entrance) { newValue in
                                if newValue.count > maxEntranceCharactersCount {
                                    entrance = String(newValue.prefix(maxEntranceCharactersCount))
                                }
                            }
                        Spacer()
                    }
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.custom(isPrivateHouse == true ? .inactiveFiledGray : .pureWhite ))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    
                    
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                
                
                // Стек Этаж , Начало
                HStack {
                    HStack(spacing: 6) {
                        Spacer()
                        Text("эт.")
                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                            .foregroundStyle(Color.custom(.textTitleGray))
                        Image("deviderVertical")
                        TextField("", text: $floor)
                            .multilineTextAlignment(.center)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .focused($focusedField, equals: .floor)
                            .submitLabel(.next)
                            .disabled(isPrivateHouse == true)
                            .onChange(of: floor) { newValue in
                                if newValue.count > maxFloorCharacters {
                                    floor = String(newValue.prefix(maxFloorCharacters))
                                }
                            }
                        Spacer()
                    }
                    
                    .cornerRadius(30)
                    .frame(width: 106, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.custom(isPrivateHouse == true ? .inactiveFiledGray : .pureWhite ))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    Spacer()
                }
                .padding(.leading, 20)
                
                HStack {
                    Toggle(isOn: $isPrivateHouse) {
                        Text("Только дом")
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                    }
                    .tint(Color.custom(.taskCompleteGreen))
                    .frame(alignment: .leading)
                    Spacer()
                    Toggle(isOn: $makePrimary) {
                        Text("Сделать основным")
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .frame(alignment: .trailing)
                            .foregroundStyle(Color.custom(.pitchBlack))
                    }
                }
                .padding(.leading, 38)
                .padding(.trailing, 21)
                
            }
            .frame(height: 230)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.custom(.bckgFieldGray))
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            )
            .padding(.horizontal, 4)
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Rectangle()
                            .tint(Color.custom(.taskCanceledOrange))
                        Text("Отмена")
                            .foregroundStyle(Color.custom(.pitchBlack))
                    }
                }
                .cornerRadius(30)
                .frame(height: 60)
                Spacer()
                Button(action: {
                    clientsVM.addAddress(
                        to: client,
                        streetName: streetName,
                        house: building,
                        apartment: apartment,
                        entrance: entrance,
                        floor: floor,
                        isPrivateHouse: isPrivateHouse,
                        roomType: roomType,
                        entranceType: entranceType,
                        makePrimary: makePrimary,
                        note: addressNote
                    )
                    dismiss()
                }) {
                    ZStack {
                        Rectangle()
                            .tint(Color.custom(.taskCompleteGreen))
                        Text("Сохранить")
                            .foregroundStyle(Color.custom(.mainBlack))
                    }
                }
                .cornerRadius(30)
                .frame(height: 60)
                .opacity(canSave ? 1 : 0.5)
                .disabled(!canSave)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            .sheet(isPresented: $showStreetsView, onDismiss: {
                if let selected = streetListViewModel.selectedStreet {
                    streetName = selected.name ?? ""
                }
            }) {
                StreetsListView(viewModel: streetListViewModel)
            }
        }
    }
}
    
    
    private var canSave: Bool {
        !streetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !building.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    
}
