import SwiftUI


struct NewClientView: View {
    
   
    
    @StateObject private var viewModel = CreateClientViewModel()
    @StateObject private var streetListViewModel = StreetListViewModel()
    
    private var maxFirstNameCharactersCount: Int = 12
    private var maxLastNameCharactersCount: Int = 12
    private let maxStreetCharactersCount: Int = 49
    private let maxBuildingCharactersCount: Int = 8
    private let maxCommentCharactersCount: Int = 65
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 3
    private let maxFloorCharactersCount: Int = 3
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 20
    private let maxAddressNoteCharactersCount: Int = 72
    private let topPadding: CGFloat = 4
    
    @State private var makePrimary: Bool = false
    @State private var showStreetsView = false
    @State private var editingStreetDraftID: UUID? = nil
    @State private var StreetCharactersTextOpacity: Double = 0
    @State private var maxStreetCharactersTextOpacity: Double = 0
    @State private var showNameAndPhoneAlert = false
    @State private var showNumberExistsAlert = false
    
    
    
    
    @FocusState private var focusedField: Field?
    
    private var smallPhoneFontSize: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 13 : 15
    }
    var onCreation: ((String) -> Void)? = nil
    
    @Environment(\.dismiss)
    private var dismiss
    
    enum Field {
        case firstName
        case lastName
        case house
        case apartment
        case entrance
        case floor
        case phoneNumber
    }
    
    init(onCreation: ((String) -> Void)? = nil) {
        self.onCreation = onCreation
    }
    
    struct AddressDraftBlockView: View {
        @Binding var draft: CreateClientViewModel.AddressDraft
        let onPickStreet: () -> Void
        let onDelete: () -> Void
        let canDelete: Bool

        let maxStreetCharactersCount: Int
        let maxBuildingCharactersCount: Int
        let maxApartmentCharactersCount: Int
        let maxEntranceCharactersCount: Int
        let maxFloorCharactersCount: Int
        let maxAddressNoteCharactersCount: Int
        let smallPhoneFontSize: CGFloat

        @FocusState.Binding var focusedField: Field?

        private let roomTypes = ["кв", "оф", "каб"]
        private let entranceTypes = ["под", "вход"]

        var body: some View {
            VStack(spacing: 4) {
              
                Spacer()
                    .frame(height: 15)

                HStack {
                    Text("Улица")
                        .foregroundColor(Color.custom(.textTitleGray))
                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                        .background(Color.clear)

                    Spacer()
                }
                .padding(.leading, 36)

                HStack {
                    HStack(spacing: 6) {
                        TextEditor(text: $draft.streetName)
                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                            .foregroundStyle(Color.custom(.pitchBlack))
                            .frame(height: 40, alignment: .center)
                            .multilineTextAlignment(.leading)
                            .scrollContentBackground(.hidden)
                            .onChange(of: draft.streetName) { _, newValue in
                                if newValue.count > maxStreetCharactersCount {
                                    draft.streetName = String(newValue.prefix(maxStreetCharactersCount))
                                }
                            }
                            .offset(y: 2)

                        Spacer()

                        Button(action: {
                            onPickStreet()
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

                GeometryReader { geo in
                    let total = geo.size.width
                    let gap: CGFloat = 4
                    let available = max(0, total - gap)
                    let firstW = available * (1.0 / 3.0)
                    let secondW = available * (2.0 / 3.0)

                    HStack(spacing: gap) {
                        VStack(spacing: 10) {
                            HStack(spacing: 6) {
                                Text("дом")
                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                    .foregroundStyle(Color.custom(.textTitleGray))
                                    .padding(.leading, 13)

                                Image("deviderVertical")

                                TextField("", text: $draft.building)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .house)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .apartment
                                    }
                                    .onChange(of: draft.building) { newValue in
                                        if newValue.count > maxBuildingCharactersCount {
                                            draft.building = String(newValue.prefix(maxBuildingCharactersCount))
                                        }
                                    }

                                Spacer()
                            }
                            .cornerRadius(30)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.custom(.pureWhite))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )

                            HStack(spacing: 6) {
                                Text("эт")
                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                    .foregroundStyle(Color.custom(.textTitleGray))
                                    .padding(.leading, 13)

                                Image("deviderVertical")

                                TextField("", text: $draft.floor)
                                    .multilineTextAlignment(.center)
                                    .disabled(draft.isPrivateHouse)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                                    .focused($focusedField, equals: .floor)
                                    .submitLabel(.next)
                                    .onChange(of: draft.floor) { newValue in
                                        if newValue.count > maxFloorCharactersCount {
                                            draft.floor = String(newValue.prefix(maxFloorCharactersCount))
                                        }
                                    }

                                Spacer()
                            }
                            .cornerRadius(30)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.custom(draft.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                        }
                        .frame(width: firstW, alignment: .leading)

                        VStack {
                            HStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    Menu {
                                        ForEach(roomTypes, id: \.self) { type in
                                            Button(type) {
                                                draft.roomType = type
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 1) {
                                            Text(draft.roomType)
                                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                .foregroundColor(Color.custom(.pitchBlack))

                                            Image("menuTriangle")
                                                .padding(.leading, 2)
                                                .offset(y: 1.2)
                                        }
                                        .frame(height: 15, alignment: .center)
                                        .frame(width: 38)
                                    }
                                    .padding(.leading, 13)
                                    .disabled(draft.isPrivateHouse)

                                    Image("deviderVertical")

                                    TextField("", text: $draft.apartment)
                                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                                        .foregroundStyle(Color.custom(.pitchBlack))
                                        .multilineTextAlignment(.center)
                                        .disabled(draft.isPrivateHouse)
                                        .focused($focusedField, equals: .apartment)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .entrance
                                        }
                                        .onChange(of: draft.apartment) { newValue in
                                            if newValue.count > maxApartmentCharactersCount {
                                                draft.apartment = String(newValue.prefix(maxApartmentCharactersCount))
                                            }
                                        }

                                    Spacer()
                                }
                                .cornerRadius(30)
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.custom(draft.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                )

                                HStack(spacing: 6) {
                                    Menu {
                                        ForEach(entranceTypes, id: \.self) { type in
                                            Button(type) {
                                                draft.entranceType = type
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 1) {
                                            Text(draft.entranceType)
                                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                .foregroundStyle(Color.custom(.pitchBlack))

                                            Image("menuTriangle")
                                                .padding(.leading, 2)
                                                .offset(y: 1.2)
                                        }
                                        .frame(height: 15, alignment: .center)
                                        .frame(width: 38)
                                    }
                                    .padding(.leading, 13)
                                    .disabled(draft.isPrivateHouse)

                                    Image("deviderVertical")
                                        .padding(.leading, 2)

                                    TextField("", text: $draft.entrance)
                                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                                        .foregroundStyle(Color.custom(.pitchBlack))
                                        .multilineTextAlignment(.center)
                                        .disabled(draft.isPrivateHouse)
                                        .focused($focusedField, equals: .entrance)
                                        .submitLabel(.next)
                                        .onSubmit {
                                            focusedField = .floor
                                        }
                                        .onChange(of: draft.entrance) { newValue in
                                            if newValue.count > maxEntranceCharactersCount {
                                                draft.entrance = String(newValue.prefix(maxEntranceCharactersCount))
                                            }
                                        }

                                    Spacer()
                                }
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.custom(draft.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                )
                            }

                            Spacer()

                            
                        }
                        .frame(width: secondW, alignment: .leading)
                        
                        
                    }
                }
                .frame(height: 90)
                .padding(.top, 10)
                .padding(.horizontal, 20)
                
                HStack {
                    
                    Toggle(isOn: $draft.makePrimary) {
                        HStack {
                            Spacer()
                            Text("Сделать основным")
                                .font(.custom(Montserrat.regular.rawValue, size: smallPhoneFontSize))
                                .frame(alignment: .trailing)
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                    }
                    .tint(Color.custom(.taskCompleteGreen))
                    
                    Spacer()
                    Toggle(isOn: $draft.isPrivateHouse) {
                        HStack {
                            Spacer()
                            Text("Только дом")
                                .font(.custom(Montserrat.regular.rawValue, size: smallPhoneFontSize))
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                    }
                    .tint(Color.custom(.taskCompleteGreen))
                    .frame(alignment: .leading)
                }
                .padding(.leading, 25)
                .padding(.trailing, 21)


                HStack {
                    Text("Комментарий к адресу")
                        .foregroundColor(Color.custom(.textTitleGray))
                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                        .background(Color.clear)

                    Spacer()
                }
                .padding(.leading, 37)
                .frame(height: 12)
                .padding(.top, 17)

                ZStack {
                    Color.custom(.pureWhite)

                    TextEditor(text: $draft.addressNote)
                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                        .foregroundStyle(Color.custom(.pitchBlack))
                        .padding(.horizontal, 12)
                        .frame(height: 60)
                        .multilineTextAlignment(.leading)
                        .scrollContentBackground(.hidden)
                        .background(Color.custom(.pureWhite))
                        .onChange(of: draft.addressNote) { newValue in
                            if newValue.count > maxAddressNoteCharactersCount {
                                draft.addressNote = String(newValue.prefix(maxAddressNoteCharactersCount))
                            }
                        }
                }
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                )
                .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 10)
            }
            .frame(maxHeight: 345)
        }
    }
    private func bindingForDraft(id: UUID) -> Binding<CreateClientViewModel.AddressDraft>? {
        guard viewModel.addressDrafts.firstIndex(where: { $0.id == id }) != nil else {
            return nil
        }

        return Binding(
            get: {
                if let currentIndex = viewModel.addressDrafts.firstIndex(where: { $0.id == id }),
                   viewModel.addressDrafts.indices.contains(currentIndex) {
                    return viewModel.addressDrafts[currentIndex]
                }
                // fallback to first valid element to avoid crash
                return viewModel.addressDrafts.first ?? CreateClientViewModel.AddressDraft()
            },
            set: { newValue in
                if let currentIndex = viewModel.addressDrafts.firstIndex(where: { $0.id == id }),
                   viewModel.addressDrafts.indices.contains(currentIndex) {
                    viewModel.addressDrafts[currentIndex] = newValue
                }
            }
        )
    }
    
    var body: some View {

        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                //main VStack start
                VStack {
                    
                    VStack  {
                        HStack {
                            Text("• ")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("НОВЫЙ ")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("КЛИЕНТ")
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text(" •")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                        
                        .padding(.top, 31)
                        
                        Spacer()
                            .frame(height: 17)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight])
                            .fill(Color.custom(.bckgFieldGray))
                        
                    )
                    .overlay(
                        RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    
                    
                    //first and last name vstack start
                    VStack(spacing: 4) {
                        Spacer()
                            .frame(height: 20)
                        ZStack {
                            Color.custom(.pureWhite)
                                .cornerRadius(20)
                            
                            VStack {
                                
                                TextField("Имя", text: $viewModel.firstName)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundColor(.custom(.pitchBlack))
                                    .padding(.leading, 16)
                                    .focused($focusedField, equals: .firstName)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .lastName
                                    }
                                    .onChange(of: viewModel.firstName) { newValue in
                                        if newValue.count > maxFirstNameCharactersCount { viewModel.firstName = String(newValue.prefix(maxFirstNameCharactersCount))
                                            
                                        }
                                    }
                                
                                Rectangle()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                                    .foregroundColor(Color.custom(.strokeGray))
                                    .padding(.leading, 11)
                                    .padding(.trailing, 10)
                                
                                TextField("Фамилия (не обязательно)", text: $viewModel.lastName)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundColor(.custom(.pitchBlack))
                                    .padding(.leading, 16)
                                    .onChange(of: viewModel.lastName) { newValue in
                                        if newValue.count > maxLastNameCharactersCount {
                                            viewModel.lastName = String(newValue.prefix(maxLastNameCharactersCount))
                                        }
                                    }
                                    .focused($focusedField, equals: .lastName)
                                
                                
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                            
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .padding(.vertical, 8)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)
                        .frame(height: 110, alignment: .center)
                        
                        Spacer()
                            .frame(height: 10)
                    }
                    .frame(maxHeight: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 4)
                    .padding(.top, topPadding)
                    //first and last name vstack end
                    
                    
                    
                    //Contact VStack start
                    VStack(spacing: 4) {
                        Spacer()
                            .frame(height: 15)
                        HStack {
                            Text("Контакт")
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .background(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        HStack {
                            ZStack {
                                Color.custom(.pureWhite)
                                TextField("", text: $viewModel.phoneDigits)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundColor(.custom(.pitchBlack))
                                    .padding(.leading, 16)
                                    .focused($focusedField, equals: .phoneNumber)
                                    .textContentType(.telephoneNumber)
                                    .onChange(of: viewModel.phoneDigits) { newValue in
                                        if newValue.count > maxPhoneNumberCharactersCount {
                                            viewModel.phoneDigits = String(newValue.prefix(maxPhoneNumberCharactersCount))
                                        }
                                        
                                    }
                            }
                            .cornerRadius(60)
                            .frame(maxWidth: 190)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 60)
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                            Spacer()
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                            .frame(height: 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .frame(maxHeight: 80)
                    .padding(.horizontal, 4)
                    .padding(.top, topPadding)
                    //Contact VStack end
                    
                    //Description VStack Start
                    VStack(spacing: 4) {
                        Spacer()
                            .frame(height: 15)
                        HStack {
                            Text("Описание (не обязательно)")
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .background(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(.horizontal, 21)
                        
                        
                        ZStack {
                            Color.custom(.pureWhite)
                            TextEditor(text:  $viewModel.comment)
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 16)
                                .frame(height: 80)
                                .scrollContentBackground(.hidden)
                                .focused($focusedField, equals: .phoneNumber)
                                .textContentType(.telephoneNumber)
                                .onChange(of: viewModel.comment) { newValue in
                                    if newValue.count > maxCommentCharactersCount {
                                        viewModel.comment = String(newValue.prefix(maxCommentCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 10)
                        
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 4)
                    .padding(.top, topPadding)
                    
                    //Description VStack end
                    
                    
                    //Address VStack start
                    VStack(spacing: 4) {
                        ForEach(viewModel.addressDrafts.map(\.id), id: \.self) { draftID in
                            if let draftBinding = bindingForDraft(id: draftID) {
                                AddressDraftBlockView(
                                    draft: draftBinding,
                                    onPickStreet: {
                                        editingStreetDraftID = draftID
                                        showStreetsView = true
                                    },
                                    onDelete: { },
                                    canDelete: viewModel.addressDrafts.count > 1,
                                    maxStreetCharactersCount: maxStreetCharactersCount,
                                    maxBuildingCharactersCount: maxBuildingCharactersCount,
                                    maxApartmentCharactersCount: maxApartmentCharactersCount,
                                    maxEntranceCharactersCount: maxEntranceCharactersCount,
                                    maxFloorCharactersCount: maxFloorCharactersCount,
                                    maxAddressNoteCharactersCount: maxAddressNoteCharactersCount,
                                    smallPhoneFontSize: smallPhoneFontSize,
                                    focusedField: $focusedField
                                )
                            }
                        }

                        HStack {
                            Spacer()

                            Button(action: {
                                viewModel.addressDrafts.append(.init())
                                print("➕ New address draft added. Total drafts: \(viewModel.addressDrafts.count)")
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.pitchBlack)
                                    .frame(width: 30, height: 30)
                            }
                            
                            Button(action: {
                                guard viewModel.addressDrafts.count > 1 else { return }

                                let removed = viewModel.addressDrafts.last?.id
                                viewModel.addressDrafts.removeLast()

                                if editingStreetDraftID == removed {
                                    editingStreetDraftID = nil
                                }

                                print("➖ Last address draft removed. Total drafts: \(viewModel.addressDrafts.count)")
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.pitchBlack)
                                    .frame(width: 30, height: 30)
                                    .opacity(viewModel.addressDrafts.count == 1 ? 0.5 : 1)
                                   
                            }
                            .disabled(viewModel.addressDrafts.count <= 1)

                            Spacer()
                        }
                    }
                    .padding(.bottom, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 4)
                    .padding(.top, topPadding)
                    //Address VStack end
                    
                   
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.taskCanceledOrange))
                                Text("Отменить")
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                            }
                        }
                        .cornerRadius(30)
                        .frame(height: 60)
                        
                        Spacer()
                        
                        Button(action: {
                            // Сначала проверяем, заполнены ли имя и номер телефона
                            if !viewModel.hasRequiredNameAndPhone() {
                                showNameAndPhoneAlert = true
                                return
                            }
                            
                            // Затем проверяем уникальность номера телефона
                            if !viewModel.hasUniquePhone() {
                                showNumberExistsAlert = true
                                return
                            }
                            
                            // Если обе проверки пройдены — создаём клиента
                            onCreation?(viewModel.firstName)
                            viewModel.createClient()
                            dismiss()
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.taskCompleteGreen))
                                Text("Cоздать")
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                            }
                        }
                        .opacity(viewModel.canCreateClient() ? 1 : 0.5)
                        .cornerRadius(30)
                        .frame(height: 60)
                      
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                } // end of main VStack
                
                
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        
        .sheet(isPresented: $showStreetsView, onDismiss: {
            if let selected = streetListViewModel.selectedStreet,
               let editingID = editingStreetDraftID,
               let index = viewModel.addressDrafts.firstIndex(where: { $0.id == editingID }) {
                viewModel.addressDrafts[index].streetName = selected.name ?? ""
            }
            editingStreetDraftID = nil
        }) {
            StreetsListView(viewModel: streetListViewModel)
        }
        
        .alert(isPresented: $showNameAndPhoneAlert) {
            Alert(title: Text("Ошибка"), message: Text("Заполните Имя и телефон"), dismissButton: .default(Text("OK")))
        }
        
        .alert(isPresented: $showNumberExistsAlert) {
            Alert(title: Text("Ошибка"), message: Text("Такой телефон уже занят"), dismissButton: .default(Text("OK")))
        }
        
        .onAppear {
        }
    }
}


#Preview {
    NewClientView()
}
