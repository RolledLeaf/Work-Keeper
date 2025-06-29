import SwiftUI

struct NewTaskView: View {
    enum Field {
        case firstName
        case lastName
        case phoneNumber
    }
    
    @State private var firstName = ""
    @State private var roomType = "кв"
    @State private var entranceType = "под"
    @State private var street = ""
    @State private var description = ""
    @State private var building = ""
    @State private var apartment = ""
    @State private var entrance = ""
    @State private var floor = ""
    @State private var countryCode = ""
    @State private var phoneNumber = ""
    @State private var costText: String = ""
    @State private var contractAmountText: String = ""
    
    private var maxFirstNameCharactersCount: Int = 13
    private let maxBuildingCharactersCount: Int = 8
    private let maxStreetCharactersCount: Int = 44
    private let maxDescriptionCharactersCount: Int = 85
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 3
    private let maxFloorCharactersCount: Int = 3
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 14
    private let maxContractAmountCharacters: Int = 6
    private let maxCostCharacters: Int = 6
    
    
    @State var contractAmount: Double = 0
    @State var cost: Double = 0
    @State private var maxStreetCharactersTextOpacity: Double = 0
    @State private var maxDescriptionCharactersTextOpacity: Double = 0
    @State private var isPrivateHouse = false
    @State private var isRemote = false
    @State private var showStreetsView = false
    @State private var selectedDate = Date()
    @FocusState private var focusedField: Field?
    
    var totalAmount: Double {
        contractAmount - cost
    }
    
   
    
    var body: some View {
        
        let roomTypes = ["кв", "оф", "каб"]
        let entranceTypes = ["под", "вход"]
        
        
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                VStack {
                    Text("Новое задание")
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
                        
                        DatePicker("time", selection: $selectedDate, displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 70, maxHeight: 35)
                        .contentShape(Rectangle())
                        
                        
                        
                        
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 120, maxHeight: 35)
                        .contentShape(Rectangle())
                        
                    }
                    .padding(.trailing, 20)
                    
                    ZStack {
                        Color.white
                        TextEditor(text: $description)
                            .font(.system(size: 20, weight: .regular, design: .default))
                            .padding(.horizontal, 16)
                            .frame(minHeight: 80, maxHeight: 100)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.leading)
                            .onChange(of: description) { newValue in
                                if newValue.count > maxDescriptionCharactersCount {
                                    description = String(newValue.prefix(maxDescriptionCharactersCount))
                                }
                                
                                if description.count >= maxDescriptionCharactersCount {
                                    maxDescriptionCharactersTextOpacity = 1
                                } else { maxDescriptionCharactersTextOpacity = 0
                                        
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
                        .opacity(maxDescriptionCharactersTextOpacity)
                    
                    Spacer()
                        .frame(height: 20)
                    
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
                    .padding(.leading, 20)
                    .padding(.trailing, 33)
                    
                    HStack {
                        ZStack {
                            Color.white
                                .cornerRadius(8)
                            
                            HStack {
                                TextField("Имя", text: $firstName)
                                    .font(.system(size: 19, weight: .regular, design: .default))
                                    .padding(.leading, 11)
                                    .background(Color.clear)
                                    .submitLabel(.next)
                                    .onChange(of: firstName) { newValue in
                                        if newValue.count > maxFirstNameCharactersCount { firstName = String(newValue.prefix(maxFirstNameCharactersCount))
                                            
                                        }
                                    }
                                
                                Button(action: {
                                    //action
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
                                TextField("", text: $phoneNumber)
                                    .font(.system(size: 19, weight: .regular, design: .default))
                                    .foregroundColor(.black)
                                    .offset(x: 8)
                                    .keyboardType(.phonePad)
                                    .onChange(of: phoneNumber) { newValue in
                                        if newValue.count > maxPhoneNumberCharactersCount {
                                            phoneNumber = String(newValue.prefix(maxPhoneNumberCharactersCount))
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
                        
                        Toggle("", isOn: $isRemote)
                            .padding(.horizontal)
                            .padding(.trailing, 40)
                    }
                    
                    ZStack {
                        Color.white
                        
                        HStack {
                            
                            Spacer()
                            TextEditor(text: $street)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .frame(width: 320)
                                .frame(height: 50)
                                .lineLimit(1, reservesSpace: false)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.leading)
                            //.onChange(of: street) { oldValue, newValue in
                                .onChange(of: street) { newValue in
                                    if newValue.count > maxStreetCharactersCount {
                                        street = String(newValue.prefix(maxStreetCharactersCount))
                                    }
                                    if street.count >= maxStreetCharactersCount  {
                                        maxStreetCharactersTextOpacity = 1
                                    } else {
                                        maxStreetCharactersTextOpacity = 0
                                    }
                                }
                            
                            
                            
                            Spacer()
                            
                            Button(action: {
                                showStreetsView = true
                            }) {
                                Image(systemName: "chevron.right")
                                
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
                        .opacity(maxStreetCharactersTextOpacity)
                    //Street section end
                    
                    
                    
                    
                    
                    HStack {
                        
                        Text("дом -")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        
                        ZStack {
                            Color.white
                            TextField("", text: $building)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: building) { newValue in
                                    if newValue.count > maxBuildingCharactersCount {
                                        building = String(newValue.prefix(maxBuildingCharactersCount))
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
                            ForEach(roomTypes, id: \.self) { type in
                                Button(type) {
                                    roomType = type
                                }
                            }
                        } label: {
                            Text(roomType)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 5)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.black)
                        }
                        ZStack {
                            Color.white
                            TextField("", text: $apartment)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: apartment) { newValue in
                                    if newValue.count > maxApartmentCharactersCount {
                                        apartment = String(newValue.prefix(maxApartmentCharactersCount))
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
                            ForEach(entranceTypes, id: \.self) { type in
                                Button(type) {
                                    entranceType = type
                                }
                            }
                        } label: {
                            Text(entranceType)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 5)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.black)
                        }
                        ZStack {
                            Color.white
                            TextField("", text: $entrance)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: entrance) { newValue in
                                    if newValue.count > maxEntranceCharactersCount {
                                        entrance = String(newValue.prefix(maxEntranceCharactersCount))
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
                            Color.white
                            TextField("", text: $floor)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 19, weight: .regular, design: .default))
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
                        
                        Toggle("", isOn: $isPrivateHouse)
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
                        
                        TextField("0", text: $contractAmountText)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .frame(width: 100, height: 30)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .onChange(of: contractAmountText) { newValue in
                                    if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                        contractAmount = value
                                    } else {
                                        contractAmount = 0
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
                        
                        TextField("0", text: $costText)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .frame(width: 100, height: 30)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .onChange(of: costText) { newValue in
                                    if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                        cost = value
                                    } else {
                                        cost = 0
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
                        Text("Итого")
                            .font(.custom(SFPro.bold.rawValue, size: 24))
                        
                        Text(totalAmount.formattedCurrency())
                            .font(.custom(SFPro.bold.rawValue, size: 24))
                    }
                    
                    
                    Spacer()
                        .frame(height: 20)
                    
                    
                    
                    
                    
                    HStack {
                        Button(action: {
                            //action
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
                            //action
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.inactiveButtonGray))
                                Text("Cоздать")
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
    }
}


#Preview {
    NewTaskView()
}



