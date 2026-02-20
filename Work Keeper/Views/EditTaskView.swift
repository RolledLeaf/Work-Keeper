import SwiftUI

struct EditTaskView: View {
    
    @ObservedObject var viewModel: EditTaskViewModel
    var onSave: ((String) -> Void)?
    @StateObject private var clientsListViewModel = ClientsListViewModel()
    @StateObject private var streetListViewModel = StreetListViewModel()
    

    @Environment(\.dismiss)
    private var dismiss
   
    private var maxFirstNameCharactersCount: Int = 13
    private let maxBuildingCharactersCount: Int = 9
    private let maxStreetCharactersCount: Int = 49
    private let maxDescriptionCharactersCount: Int = 85
    private let maxCommentCharactersCount: Int = 85
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 4
    private let maxFloorCharactersCount: Int = 4
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 16
    private let maxContractAmountCharacters: Int = 7
    private let maxCostCharacters: Int = 7
    private let maxExtraPaymentCharacters: Int = 7
    private let maxFloorCharacters: Int = 4
    
    @State private var phoneMasked: String = ""
    @State private var previousPhoneMasked: String = ""
    @State private var alertMessage: String = "Заполните обязательные поля"
    
    @State private var StreetCharactersTextOpacity: Double = 0
    @State private var maxCharactersWarningTextOpacity: Double = 0
    @State private var maxCharactersWarningCommentTextOpacity: Double = 0
    @State private var streetChevronOpacity: Double = 1
    @State private var showStreetsView = false
    @State private var showClientListToPickView = false
    @State private var showEditTaskAlert = false
    @State private var hideScrollContentBackground = false
    @State private var isDatePickerPresented = false
    @State private var isTimePickerPresented = false
    @State private var streetTextFieldColor: CustomColor = .pureWhite
    @State private var houseTextFieldColor: CustomColor = .pureWhite
    @State private var textFieldColor: CustomColor = .pureWhite
    @FocusState private var focusedField: Field?
    
    private var adaptiveCardRadius: CGFloat {
        DeviceLayout.cardRadius(for: UIScreen.main.bounds.width)
    }
 
   
    enum Field {
        case house
        case apartment
        case entrance
        case floor
        case contractAmount
    }
    
    private func missingRequiredFieldsMessage() -> String? {
        var missing: [String] = []
        
        if viewModel.firstName.isBlank {
            missing.append("Имя клиента")
        }
        if viewModel.phoneDigits.isBlank {
            missing.append("контакт")
        }
        if !viewModel.isRemote && viewModel.streetName.isBlank {
            missing.append("название улицы")
        }
        if !viewModel.isRemote && viewModel.house.isBlank {
            missing.append("номер дома")
        }
        
        guard !missing.isEmpty else { return nil }
        
        if missing.count == 1 {
            return "\(missing[0])."
        } else {
            let allButLast = missing.dropLast().joined(separator: ", ")
            let last = missing.last ?? ""
            return " \(allButLast) и \(last)."
        }
    }
    
    
    init(viewModel: EditTaskViewModel, onSave: ((String) -> Void)? = nil) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onSave = onSave
    }
    var body: some View {
   
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                VStack {
                    
                    VStack  {
                        HStack {
                            Text("• ")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("РЕДАКТИРОВАТЬ ")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("ЗАДАНИЕ")
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text(" •")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                        .frame(height: 22)
                        .padding(.top, 31)
                        
                        
                        HStack {
                            Text("Описание")
                            
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .background(Color.clear)
                            Spacer()
                        }
                        .padding(.leading, 36)
                        .padding(.top, 27)
                        .padding(.trailing, 20)
                        .frame(height: 16)
                        
                        ZStack {
                            Color.custom(.pureWhite)
                            
                            TextEditor(text: $viewModel.descriptionText)
                            
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 12)
                                .frame(height: 80)
                                .multilineTextAlignment(.leading)
                                .scrollContentBackground(.hidden) // скрыть внутренний фон
                                .background(Color.custom(.pureWhite))
                                .onChange(of: viewModel.descriptionText) { newValue in
                                    if newValue.count > maxDescriptionCharactersCount {
                                        viewModel.descriptionText = String(newValue.prefix(maxDescriptionCharactersCount))
                                    }
                                    
                                    
                                    
                                }
                            
                        }
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        
                        .padding(.horizontal, 20)
                        .padding(.top, 7)
                        
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    
                    .background(
                        RoundedCorner(radius: adaptiveCardRadius, corners: [.allCorners])
                            .fill(Color.custom(.bckgFieldGray))
                    )
                    .overlay(
                        RoundedCorner(radius: adaptiveCardRadius, corners: [.allCorners])
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 0)
            
                    VStack {
                            Text("Комментарий")
                               
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                        .padding(.leading, 36)
                        .padding(.top, 27)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 16)
                        
                        ZStack {
                            Color.custom(.pureWhite)
                            
                            TextEditor(text: $viewModel.comment)
                            
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 12)
                                .frame(height: 80)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .scrollContentBackground(.hidden) // скрыть внутренний фон
                                .background(Color.custom(.pureWhite))
                                .onChange(of: viewModel.comment) { newValue in
                                    if newValue.count > maxDescriptionCharactersCount {
                                        viewModel.comment = String(newValue.prefix(maxDescriptionCharactersCount))
                                    }
                                }
                            
                        }
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 7)
                        
                        
                        Spacer()
                            .frame(height: 20)
                    
                   
                }
                .background(
                    RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
                        .fill(Color.custom(.bckgFieldGray))
                )
                .overlay(
                    RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight, .topRight, .topLeft])
                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                )
                .padding(.top, 3)
                .padding(.horizontal, 3)
                    
                    
                
                    
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.custom(.bckgFieldGray))
                            Image("dateTime")
                                .resizable()
                                .frame(width: 16, height: 16)
                            
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .frame(width: 30, height: 30)
                        
                        
                        DatePickerField(date: $viewModel.scheduledAt) {
                            isDatePickerPresented = true
                        }
                        
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.custom(.bckgFieldGray))
                            Image("clock")
                                .resizable()
                                .frame(width: 16, height: 16)
                            
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .frame(width: 30, height: 30)
                        
                        TimePickerField(date: $viewModel.scheduledAt, minuteInterval: 5) {
                            isTimePickerPresented = true
                        }
                        
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                    
                    
                   VStack { // Начало, клиент и телефон
                        HStack {
                            VStack(spacing: 4) {
                                Text("Клиент")
                                    .foregroundColor(Color.custom(.textTitleGray))
                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                    .background(Color.clear)
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                    .frame(height: 12)
                                    .padding(.leading, 16)
                                
                                ZStack {
                                    Color.custom(.pureWhite)
                                    HStack {
                                        TextField("Имя", text: $viewModel.firstName)
                                            .font(.custom(Montserrat.regular.rawValue, size: 15))
                                            .foregroundStyle(Color.custom(.pitchBlack))
                                            .padding(.leading, 16)
                                            .background( Color.custom(.pureWhite))
                                            .submitLabel(.next)
                                            .onChange(of: viewModel.firstName) { newValue in
                                                if newValue.count > maxFirstNameCharactersCount { viewModel.firstName = String(newValue.prefix(maxFirstNameCharactersCount))
                                                }
                                            }
                                      
                                            
                                        Button(action: {
                                            showClientListToPickView = true
                                        })
                                        {
    
                                        }
                                        .buttonStyle(PressImageButtonStyle(normalImage: "clientsInactive", pressedImage: "clientsActive"))
                                        .padding(.trailing, 5)
                                    }
                                    
                                }
                                .cornerRadius(60)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                )
                                .frame(height: 40, alignment: .center)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                Text("Контакт")
                                
                                    .foregroundColor(Color.custom(.textTitleGray))
                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                    .background(Color.clear)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 12)
                                    .padding(.leading, 16)
                                
                                ZStack {
                                    Color.custom(.pureWhite)
                                    TextField("", text: $viewModel.phoneDigits)
                                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                                        .foregroundColor(.custom(.pitchBlack))
                                        .padding(.leading, 16)
                                        .onChange(of: viewModel.phoneDigits) { newValue in
                                            if newValue.count > maxPhoneNumberCharactersCount { viewModel.phoneDigits = String(newValue.prefix(maxPhoneNumberCharactersCount))
                                            }
                                        }
                                }
                                .cornerRadius(60)
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                )
                            }
                        }
                        .padding(.top, 17)
                        .padding(.horizontal, 20)

             
                        Spacer()
                    } // Клиент и телефон, конец
                    .frame(height: 93)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 4)
                   

                  
                    VStack(spacing: 4) {
                    //address section
                    HStack {
                        Text("Улица")
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                            .background(Color.clear)
                            
                        Spacer()
                    }
                    .padding(.leading, 37)
                    .frame(height: 12)
                    
                        ZStack {
                            Color.custom(viewModel.isRemote ? .inactiveFiledGray : .pureWhite)
                            HStack {
                                TextEditor(text: $viewModel.streetName)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                                    .frame(height: 40, alignment: .center)
                                    .multilineTextAlignment(.leading)
                                    .disabled(viewModel.remoteEditingBlock)
                                 
                                    .scrollContentBackground(.hidden)
                                    .onChange(of: viewModel.streetName) { _, newValue in
                                        if newValue.count > maxStreetCharactersCount {
                                            viewModel.streetName = String(newValue.prefix(maxStreetCharactersCount))
                                        }
                                        if viewModel.streetName.count >= maxStreetCharactersCount  {
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
                                        .opacity(streetChevronOpacity)
                                }
                                .tint(Color.custom(.pitchBlack))
                                .disabled(viewModel.isRemote ? true : false)
                                
                            }
                           
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
                        }
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        .frame(height: 40)
                        .padding(.horizontal, 21)
                    
                    
                    
                    //Street section end
                    
                        HStack {
                            
                            
                            
                            HStack(spacing: 6) {
                                Spacer()
                                Text("дом")
                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                    .foregroundStyle(Color.custom(.textTitleGray))
                                
                                Image("deviderVertical")
                                
                                TextField("", text: $viewModel.house)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .house)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .apartment
                                    }
                                    .disabled(viewModel.remoteEditingBlock)
                                
                                    .onChange(of: viewModel.house) { newValue in
                                        if newValue.count > maxBuildingCharactersCount {
                                            viewModel.house = String(newValue.prefix(maxBuildingCharactersCount))
                                        }
                                    }
                                Spacer()
                            }
                            
                            .cornerRadius(30)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(  Color.custom(houseTextFieldColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                        
                        
                        Spacer()
                        
                            HStack(spacing: 6) {
                                Spacer()
                        Menu {
                            ForEach(viewModel.roomTypes, id: \.self) { type in
                                Button(type) {
                                    viewModel.roomType = type
                                }
                             
                            }
                        } label: {
                            Text(viewModel.roomType ?? "кв.")
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .foregroundColor(Color.custom(.pitchBlack))
                                .frame(width: 25)
                   
                        }
                        .disabled(viewModel.privateHouseBlock)
                                
                                Image("deviderVertical")
                        
                    
                            TextField("", text: $viewModel.apartment)
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.privateHouseBlock)
                                .focused($focusedField, equals: .apartment)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .entrance
                                }
                                .onChange(of: viewModel.apartment) { newValue in
                                    if newValue.count > maxApartmentCharactersCount {
                                        viewModel.apartment = String(newValue.prefix(maxApartmentCharactersCount))
                                    }
                                }
                       
                                Spacer()
                            }
                        
                            .cornerRadius(30)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(  Color.custom(textFieldColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                                
                                
                        Spacer()
                        
                            HStack(spacing: 6) {
                                Spacer()
                        Menu {
                            ForEach(viewModel.entranceTypes, id: \.self) { type in
                                Button(type) {
                                    viewModel.entranceType = type
                                }
                            }
                        } label: {
                            Text(viewModel.entranceType ?? "под.")
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .frame(width: 32)
                        }
                        .disabled(viewModel.privateHouseBlock)
                                
                                Image("deviderVertical")
                      
                            TextField("", text: $viewModel.entrance)
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .frame(width: 32)
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.privateHouseBlock)
                                .focused($focusedField, equals: .entrance)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .floor
                                }
                                .onChange(of: viewModel.entrance) { newValue in
                                    if newValue.count > maxEntranceCharactersCount {
                                        viewModel.entrance = String(newValue.prefix(maxEntranceCharactersCount))
                                    }
                                }
                                Spacer()
                        
                            }
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(  Color.custom(textFieldColor))
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
                            TextField("", text: $viewModel.floor)
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.privateHouseBlock)
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .focused($focusedField, equals: .floor)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .contractAmount
                                }
                                .onChange(of: viewModel.floor) { newValue in
                                    if newValue.count > maxFloorCharacters {
                                        viewModel.floor = String(newValue.prefix(maxFloorCharacters))
                                    }
                                }
                            Spacer()
                        }
                    
                        .cornerRadius(30)
                        .frame(width: 106, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(  Color.custom(textFieldColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        Toggle(isOn: $viewModel.isPrivateHouse) {
                            Text("Только дом")
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                        .tint(Color.custom(.taskCompleteGreen))
                        .frame(alignment: .leading)
                        .disabled(viewModel.shouldBlockPrivate)
                        .onChange(of: viewModel.isPrivateHouse) { newValue in
                            if newValue == true {
                                viewModel.shouldBlockRemote = true
                                viewModel.privateHouseBlock = true
                                textFieldColor = CustomColor.inactiveFiledGray
                            } else {
                                viewModel.privateHouseBlock = false
                                viewModel.shouldBlockRemote = false
                                textFieldColor = .pureWhite
                            }
                        }
                        
                        Spacer()
                        
                        Toggle(isOn: $viewModel.isRemote) {
                            Text("Удалёнка")
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                        .tint(Color.custom(.taskCompleteGreen))
                        .frame(alignment: .trailing)
                        
                        .disabled(viewModel.shouldBlockRemote)
                        .onChange(of: viewModel.isRemote) { _, newValue in
                            if newValue == true {
                                viewModel.remoteEditingBlock = true
                                viewModel.privateHouseBlock = true
                                viewModel.shouldBlockPrivate = true
                                hideScrollContentBackground = true
                                streetChevronOpacity = 0
                                houseTextFieldColor = CustomColor.inactiveFiledGray
                                streetTextFieldColor = CustomColor.inactiveFiledGray
                                textFieldColor = CustomColor.inactiveFiledGray
                            } else {
                                streetChevronOpacity = 1
                                viewModel.remoteEditingBlock = false
                                viewModel.privateHouseBlock = false
                                viewModel.shouldBlockPrivate = false
                                hideScrollContentBackground = false
                                textFieldColor = .pureWhite
                                houseTextFieldColor = .pureWhite
                                streetTextFieldColor = .pureWhite
                            }
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
                            .padding(.top, -4)

                    
                    VStack {
                        HStack {
                        HStack {
                            Text("Стоимость")
                                
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .background(Color.clear)
                                .frame(width: 88)
                            Image("deviderVertical")
                            
                            Spacer()
                            
                            TextField("0", text: $viewModel.contractAmountText)
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .contractAmount)
                                .onChange(of: viewModel.contractAmountText) { newValue in
                                    if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                        viewModel.contractAmount = value
                                    } else {
                                        viewModel.contractAmount = 0
                                    }
                                    
                                    if newValue.count > maxContractAmountCharacters {
                                        viewModel.contractAmountText = String(newValue.prefix( maxContractAmountCharacters))
                                    }
                                }
                            
                        }
                        .frame(height: 40)
                        .padding(.horizontal, 16)
                        .cornerRadius(30)
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
                        
                        HStack {
                        HStack {
                            Text("Издержки")
                                
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .frame(width: 88)
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .background(Color.clear)
                            
                            Image("deviderVertical")
                            
                            Spacer()
                            
                            TextField("0", text: $viewModel.costText)
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
//                                .frame(maxWidth: 100)
                                .frame(height: 30)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.costText) { newValue in
                                    if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                        viewModel.cost = value
                                    } else {
                                        viewModel.cost = 0
                                    }
                                    if newValue.count > maxCostCharacters {
                                        viewModel.costText = String(newValue.prefix(maxCostCharacters))
                                    }
                                }
                        }
                        .frame(height: 40)
                        .padding(.horizontal, 16)
                        .cornerRadius(30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(  Color.custom(.pureWhite))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 20)
                        
                        HStack {
                        HStack {
                            Text("Доплачено")
                                
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .frame(width: 88)
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .background(Color.clear)
                            
                            Image("deviderVertical")
                            
                            Spacer()
                            
                            TextField("0", text: $viewModel.extraPaymentText)
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
//                                .frame(maxWidth: 100)
                                .frame(height: 30)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.extraPaymentText) { newValue in
                                    if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                        viewModel.extraPayment = value
                                    } else {
                                        viewModel.extraPayment = 0
                                    }
                                    if newValue.count > maxCostCharacters {
                                        viewModel.extraPaymentText = String(newValue.prefix(maxCostCharacters))
                                    }
                                }
                        }
                        .frame(height: 40)
                        .padding(.horizontal, 16)
                        .cornerRadius(30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(  Color.custom(.pureWhite))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 17)
    
                        HStack {
                            Text("Итого:")
                                .font(.custom(Montserrat.bold.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            
                            Text(viewModel.totalAmount.formattedCurrency())
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            Spacer()
                        }
                        .frame(height: 15)
                       
                        .padding(.leading, 36)
                    }
                    .frame(height: 201)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.custom(.bckgFieldGray))
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                    .padding(.horizontal, 4)

                
                    
                    
                    VStack {
                        Picker("Тип оплаты", selection: $viewModel.paymentType) {
                            Text("Наличные").tag(PaymentType.cash)
                                .font(.custom(Montserrat.regular.rawValue, size: 14))
                            Text("Перевод").tag(PaymentType.transfer)
                                .font(.custom(Montserrat.regular.rawValue, size: 14))
                        }
                        
                        .pickerStyle(.segmented)
                        .disabled(viewModel.status != .completed)
                        
                        
                        
                }
                .frame(height: 38)
             
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
                            if let message = missingRequiredFieldsMessage() {
                                alertMessage = message
                                showEditTaskAlert = true
                            } else {
                                viewModel.update()
                                onSave?(viewModel.descriptionText)
                                dismiss()
                            }
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
                        .opacity(viewModel.canSaveTask() ? 1 : 0.5)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                } // end of main VStack
                

                
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            
            if isDatePickerPresented {
                Color.custom(.pitchBlack).opacity(0.9)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                DatePickerView(date: $viewModel.scheduledAt, isPresented: $isDatePickerPresented)
//                    .frame(width: 320, height: 260)
                    .frame(height: 260)
                    .background(Color.custom(.pureWhite))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
            if isTimePickerPresented {
                Color.custom(.pitchBlack).opacity(0.9)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                TimePickerView(date: $viewModel.scheduledAt, isPresented: $isTimePickerPresented)
                //                    .frame(width: 320, height: 260)
                                    .frame(height: 260)
                    .background(Color.custom(.pureWhite))
                    .cornerRadius(16)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isDatePickerPresented)
        .animation(.easeInOut(duration: 0.3), value: isTimePickerPresented)
        
        
        
        .alert(isPresented: $showEditTaskAlert) {
            if viewModel.isRemote == false {
                Alert(title: Text("Ошибка"), message: Text("Зполните хотя бы имя, контакт, название улицы и номер дома "), dismissButton: .default(Text("OK"))) } else {
                    Alert(title: Text("Ошибка"), message: Text("Зполните хотя бы имя и контакт"), dismissButton: .default(Text("OK")))
                }
        }
       
        .sheet(isPresented: $showStreetsView, onDismiss: {
            if let selected = streetListViewModel.selectedStreet {
                viewModel.streetName = selected.name ?? ""
            }
        }) {
            StreetsListView(viewModel: streetListViewModel)
        }
        
        .sheet(isPresented: $showClientListToPickView, onDismiss: {
            if let selectedClient = clientsListViewModel.selectedClient {
                viewModel.firstName = selectedClient.firstName ?? ""
                viewModel.phoneDigits = selectedClient.phone ?? ""

                if let primaryAddress = selectedClient.address?.first(where: {
                    ($0 as? Address)?.isPrimary == true
                }) as? Address {
                    viewModel.streetName = primaryAddress.street?.name ?? ""
                    viewModel.house = primaryAddress.house ?? ""
                    viewModel.apartment = primaryAddress.apartment ?? ""
                    viewModel.entrance = primaryAddress.entrance ?? ""
                  
                    viewModel.floor = "\(primaryAddress.floor ?? "")"
                }
            }
        }) {
            ClientListToPickView(viewModel: clientsListViewModel)
        }
        .onAppear {
            phoneMasked = maskRU(fromDigits: viewModel.phoneDigits)
            previousPhoneMasked = phoneMasked
        }
        
        .onAppear {
            if viewModel.isPrivateHouse {
                viewModel.shouldBlockRemote = true
                viewModel.privateHouseBlock = true
                textFieldColor = CustomColor.inactiveFiledGray
            } else {
                viewModel.privateHouseBlock = false
                viewModel.shouldBlockRemote = false
                textFieldColor = .pureWhite
            }
        }
        .onAppear {
            if viewModel.isRemote {
                viewModel.remoteEditingBlock = true
                viewModel.privateHouseBlock = true
                viewModel.shouldBlockPrivate = true
                hideScrollContentBackground = true
                streetChevronOpacity = 0
                houseTextFieldColor = CustomColor.inactiveFiledGray
                streetTextFieldColor = CustomColor.inactiveFiledGray
                textFieldColor = CustomColor.inactiveFiledGray
            } else {
                streetChevronOpacity = 1
                viewModel.remoteEditingBlock = false
                viewModel.privateHouseBlock = false
                viewModel.shouldBlockPrivate = false
                hideScrollContentBackground = false
                
            }
        }
        
        
    }
    
    // MARK: - Phone helpers
    private func digitsOnly(_ s: String) -> String {
        String(s.filter { $0.isNumber })
    }

    private func maskRU(fromDigits s: String) -> String {
        if s.isEmpty { return "" }
        var result = "+7"
        let chars = Array(s)

        result += "("
        let a = min(3, chars.count)
        result += String(chars[0..<a])
        if chars.count < 3 { return result }

        result += ")"
        let b = min(3, chars.count - 3)
        if b > 0 { result += String(chars[3..<(3 + b)]) }
        if chars.count < 6 { return result }

        result += "-"
        let c = min(2, chars.count - 6)
        if c > 0 { result += String(chars[6..<(6 + c)]) }
        if chars.count < 8 { return result }

        result += "-"
        let d = min(2, chars.count - 8)
        if d > 0 { result += String(chars[8..<(8 + d)]) }

        return result
    }
}



