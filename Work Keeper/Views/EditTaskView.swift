import SwiftUI

struct EditTaskView: View {
    
    @ObservedObject var viewModel: EditTaskViewModel
    @StateObject private var clientsListViewModel = ClientsListViewModel()
   
    private var maxFirstNameCharactersCount: Int = 13
    private let maxBuildingCharactersCount: Int = 8
    private let maxStreetCharactersCount: Int = 44
    private let maxDescriptionCharactersCount: Int = 85
    private let maxCommentCharactersCount: Int = 85
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 3
    private let maxFloorCharactersCount: Int = 3
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 14
    private let maxContractAmountCharacters: Int = 6
    private let maxCostCharacters: Int = 6
    private let maxExtraPaymentCharacters: Int = 6
    

    @State private var StreetCharactersTextOpacity: Double = 0
    @State private var maxCharachtersWarningTextOpacity: Double = 0
    @State private var maxCharachtersWarningCommentTextOpacity: Double = 0
    @State private var streetChevronOpacity: Double = 1
    @State private var showStreetsView = false
    @State private var showClientListToPickView = false
    @State private var hideScrollContentBackground = false
    @State private var textFieldColor: CustomColor = .pureWhite
 
    @Environment(\.dismiss)
    private var dismiss
    
    init(viewModel: EditTaskViewModel) {
           // Передаём viewModel в свойство @ObservedObject
           self._viewModel = ObservedObject(wrappedValue: viewModel)
       }
    var body: some View {
   
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                VStack {
                    Text("Редактирование задания")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(Color.black)
                        .offset(y: 30)
                    Spacer()
                        .frame(height: 50)
                    
                    HStack {
                        Text("Описание")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                        
                        DatePicker("time", selection: $viewModel.scheduledAt, displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 70, maxHeight: 35)
                        .contentShape(Rectangle())
                        
                        
                        
                        
                        DatePicker("Date", selection: $viewModel.scheduledAt, displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 120, maxHeight: 35)
                        .contentShape(Rectangle())
                        
                    }
                    .padding(.trailing, 20)
                    
                    ZStack {
                        Color.white
                        TextEditor(text: $viewModel.descriptionText)
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .padding(.horizontal, 16)
                            .frame(minHeight: 80, maxHeight: 100)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)
                            .onChange(of: viewModel.descriptionText) { newValue in
                                if newValue.count > maxDescriptionCharactersCount {
                                    viewModel.descriptionText = String(newValue.prefix(maxDescriptionCharactersCount))
                                }
                                
                                if viewModel.descriptionText.count >= maxDescriptionCharactersCount {
                                    maxCharachtersWarningTextOpacity = 1
                                } else { maxCharachtersWarningTextOpacity = 0
                                    
                                }
                                
                            }
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 16)
                    
                    Text("максимум символов \(maxDescriptionCharactersCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .opacity(maxCharachtersWarningTextOpacity)
                    
                    HStack {
                        Text("Комментарий")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                
                    }
                    .padding(.trailing, 20)
                    
                    ZStack {
                        Color.white
                        TextEditor(text: $viewModel.comment)
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .padding(.horizontal, 16)
                            .frame(minHeight: 80, maxHeight: 100)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)
                            .onChange(of: viewModel.comment) { newValue in
                                if newValue.count > maxCommentCharactersCount {
                                    viewModel.comment = String(newValue.prefix(maxCommentCharactersCount))
                                }
                                
                                if viewModel.comment.count >= maxCommentCharactersCount {
                                    maxCharachtersWarningCommentTextOpacity = 1
                                } else { maxCharachtersWarningCommentTextOpacity = 0
                                    
                                }
                                
                            }
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 16)
                    
                    Text("максимум символов \(maxCommentCharactersCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .opacity(maxCharachtersWarningCommentTextOpacity)
                    
                    Spacer()
                        .frame(height: 10)
                    
                    HStack {
                        Text("Клиент")
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 18, weight: .regular, design: .default))
                            .background(Color.clear)
                            .frame(width: 100, alignment: .leading)
                            .frame(height: 15)
                        
                        Spacer()
                        
                        Text("Номер телефона")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 18, weight: .regular, design: .default))
                            .background(Color.clear)
                            .frame(height: 15)
                        
                    }
                    .offset(y: -8)
                    .padding(.leading, 20)
                    .padding(.trailing, 33)
                    
                    HStack {
                        ZStack {
                            Color.white
                                .cornerRadius(8)
                            
                            HStack {
                                TextField("Имя", text: $viewModel.firstName)
                                    .font(.system(size: 19, weight: .regular, design: .default))
                                    .padding(.leading, 11)
                                    .background(Color.clear)
                                    .submitLabel(.next)
                                    .onChange(of: viewModel.firstName) { newValue in
                                        if newValue.count > maxFirstNameCharactersCount { viewModel.firstName = String(newValue.prefix(maxFirstNameCharactersCount))
                                            
                                        }
                                    }
                                
                                Button(action: {
                                    showClientListToPickView = true
                                })
                                {
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 4)
                                        .tint(Color.black)
                                }
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                            
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        .cornerRadius(8)
                        .frame(width: 170)
                        .frame(height: 40, alignment: .center)
                        
                        Spacer()
                        
                        HStack {
                            
                            ZStack {
                                Color.white
                                TextField("", text: $viewModel.phoneNumber)
                                    .font(.system(size: 19, weight: .regular, design: .default))
                                    .foregroundColor(.black)
                                    .offset(x: 8)
                                    .keyboardType(.phonePad)
                                    .onChange(of: viewModel.phoneNumber) { newValue in
                                        if newValue.count > maxPhoneNumberCharactersCount {
                                            viewModel.phoneNumber = String(newValue.prefix(maxPhoneNumberCharactersCount))
                                        }
                                    }
                            }
                            .cornerRadius(10)
                            .frame(width: 170, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                            )
                            
                        }
                        
                        
                    }
                    .padding(.horizontal, 20)
                    .offset(y: -8)
                    
                    
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.custom(.separatorLineGray))
                    
                    Spacer()
                        .frame(height: 15)
                    
                    //address section
                    HStack {
                        Text("Адрес")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        
                        Spacer()
                        
                        Text("Удалёнка")
                            .font(.custom(SFPro.italic.rawValue, size: 20))
                            .padding(.horizontal)
                            .frame(width: 150, alignment: .trailing)
                            .offset(x: 65)
                        
                        Toggle("", isOn: $viewModel.isRemote)
                            .padding(.horizontal)
                            .padding(.trailing, 40)
                            .onChange(of: viewModel.isRemote) { _, newValue in
                                if newValue == true {
                                    viewModel.shouldBlockEditing = true
                                    hideScrollContentBackground = true
                                    streetChevronOpacity = 0
                                    textFieldColor = CustomColor.inactiveFiledGray
                                } else {
                                    streetChevronOpacity = 1
                                    viewModel.shouldBlockEditing = false
                                    hideScrollContentBackground = false
                                    textFieldColor = .pureWhite
                                }
                            }
                    }
                    
                    ZStack {
                        Color.custom(textFieldColor)
                        HStack {
                            Spacer()
                            TextEditor(text: $viewModel.streetName)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .frame(width: 320)
                                .frame(height: 50)
                                .lineLimit(1, reservesSpace: false)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.leading)
                                .disabled(viewModel.shouldBlockEditing)
                                .background(Color.custom(textFieldColor))
                                .scrollContentBackground(hideScrollContentBackground ? .hidden : .visible)
                            //.onChange(of: street) { oldValue, newValue in
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
                            
                            Spacer()
                            
                            Button(action: {
                                showStreetsView = true
                            }) {
                                Image(systemName: "chevron.right")
                                    .opacity(streetChevronOpacity)
                            }
                            .tint(Color(.black))
                            .offset(x: -5)
                        }
                        
                        
                    }
                    .frame(height: 50)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        
                    )
                    .padding(.horizontal, 20)
                    
                    
                    
                    
                    Text("максимум символов \(maxStreetCharactersCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .opacity(StreetCharactersTextOpacity)
                    //Street section end
                    
                    HStack {
                        
                        Text("дом -")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        
                        ZStack {
                            Color.custom(textFieldColor)
                            TextField("", text: $viewModel.house)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.shouldBlockEditing)
                                .onChange(of: viewModel.house) { newValue in
                                    if newValue.count > maxBuildingCharactersCount {
                                        viewModel.house = String(newValue.prefix(maxBuildingCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 75, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        Spacer()
                        
                        Menu {
                            ForEach(viewModel.roomTypes, id: \.self) { type in
                                Button(type) {
                                    viewModel.roomType = type
                                }
                            }
                        } label: {
                            Text(viewModel.roomType ?? "кв.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 5)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.black)
                        }
                        
                        ZStack {
                            Color.custom(textFieldColor)
                            TextField("", text: $viewModel.apartment)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.shouldBlockEditing)
                                .onChange(of: viewModel.apartment) { newValue in
                                    if newValue.count > maxApartmentCharactersCount {
                                        viewModel.apartment = String(newValue.prefix(maxApartmentCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 66, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        Spacer()
                        
                        Menu {
                            ForEach(viewModel.entranceTypes, id: \.self) { type in
                                Button(type) {
                                    viewModel.entranceType = type
                                }
                            }
                        } label: {
                            Text(viewModel.entranceType ?? "под.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 5)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.black)
                        }
                        ZStack {
                            Color.custom(textFieldColor)
                            TextField("", text: $viewModel.entrance)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.shouldBlockEditing)
                                .onChange(of: viewModel.entrance) { newValue in
                                    if newValue.count > maxEntranceCharactersCount {
                                        viewModel.entrance = String(newValue.prefix(maxEntranceCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 37, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 17)
                    
                    // Стек Этаж - Частный дом, Начало
                    HStack {
                        
                        Text("эт -")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        ZStack {
                            Color.custom(textFieldColor)
                            TextField("", text: $viewModel.floor)
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.shouldBlockEditing)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .onChange(of: viewModel.floor) { newValue in
                                    if newValue.count > maxFloorCharactersCount {
                                        viewModel.floor = String(newValue.prefix(maxFloorCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 40, height: 30)
                        
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        
                        Text("Частный дом")
                            .font(.custom(SFPro.italic.rawValue, size: 20))
                            .padding(.horizontal)
                            .frame(width: 150)
                            .offset(x: 35)
                        
                        Toggle("", isOn: $viewModel.isPrivateHouse)
                            .padding(.horizontal)
                        
                    }
                    // Стек Этаж - Частный дом, конец
                    .padding(.horizontal, 35)
                    
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.custom(.separatorLineGray))
                    
                    
                    HStack {
                        Text("Оплата")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Договорились")
                            .padding(.leading, 21)
                            .foregroundColor(Color(.black))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                        
                        TextField("0", text: $viewModel.contractAmountText)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .frame(width: 100, height: 30)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.contractAmountText) { newValue in
                                if newValue.count > maxContractAmountCharacters {
                                    viewModel.contractAmountText = String(newValue.prefix( maxContractAmountCharacters))
                                }
                                
                                if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                    viewModel.contractAmount = value
                                } else {
                                    viewModel.contractAmount = 0
                                }
                               
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                                    .fill(Color.white)
                            )
                    }
                    .padding(.trailing, 48)
                    
                    
                    
                    
                    
                    HStack {
                        Text("Издержки")
                            .padding(.leading, 21)
                            .foregroundColor(Color(.black))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                        
                        TextField("0", text: $viewModel.costText)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .frame(width: 100, height: 30)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.costText) { newValue in
                                if newValue.count > maxCostCharacters {
                                    viewModel.costText = String(newValue.prefix(maxCostCharacters))
                                }
                                if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                    viewModel.cost = value
                               
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                                    .fill(Color.white)
                            )
                    }
                    .padding(.trailing, 48)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    HStack {
                        Text("Доплачено")
                            .padding(.leading, 21)
                            .foregroundColor(Color(.black))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                        
                        TextField("0", text: $viewModel.extraPaymentText)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .frame(width: 100, height: 30)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.extraPaymentText) { newValue in
                                if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                    viewModel.extraPayment = value
                                }
                                if newValue.count > maxExtraPaymentCharacters {
                                    viewModel.extraPaymentText = String(newValue.prefix(maxExtraPaymentCharacters))
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                                    .fill(Color.white)
                            )
                    }
                    .padding(.trailing, 48)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    Picker("Тип оплаты", selection: $viewModel.paymentType) {
                        Text("Наличные").tag(PaymentType.cash)
                        Text("Перевод").tag(PaymentType.transfer)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    
                    HStack {
                        Text("Итого")
                            .font(.custom(SFPro.bold.rawValue, size: 24))
                        
                        Text(viewModel.totalAmount.formattedCurrency())
                            .font(.custom(SFPro.bold.rawValue, size: 24))
                    }
                    
                    
                    Spacer()
                        .frame(height: 20)
                    
                    
                    
                    
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.cancelButtonRed))
                                Text("Отменить")
                                    .tint(Color.white)
                            }
                        }
                        .cornerRadius(16)
                        .frame(width: 166, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.black), lineWidth: 0.5)
                        )
                        
                        Button(action: {
                            viewModel.update()
                            dismiss()
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.inactiveButtonGray))
                                Text("Сохранить")
                                    .tint(Color.white)
                            }
                        }
                        .cornerRadius(16)
                        .frame(width: 166, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(.black), lineWidth: 0.5)
                        )
                    }
                    Spacer()
                } // end of main VStack
                
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        
        .sheet(isPresented: $showStreetsView) {
            StreetsListView()
        }
        .sheet(isPresented: $showClientListToPickView, onDismiss: {
            if let selectedClient = clientsListViewModel.selectedClient {
                viewModel.firstName = selectedClient.firstName ?? ""
                viewModel.phoneNumber = selectedClient.phone ?? ""
                if let primaryAddress = selectedClient.address?.first(where: {
                    ($0 as? Address)?.isPrimary == true
                }) as? Address {
                    viewModel.streetName = primaryAddress.street?.name ?? ""
                    viewModel.house = primaryAddress.house ?? ""
                    viewModel.apartment = primaryAddress.apartment ?? ""
                    viewModel.entrance = primaryAddress.entrance ?? ""
                  
                    viewModel.floor = "\(primaryAddress.floor)"
                }
            }
        }) {
            ClientListToPickView(viewModel: clientsListViewModel)
        }
    }
}



