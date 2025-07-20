import SwiftUI

struct NewClientView: View {
    
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var roomType = "кв"
    @State private var entranceType = "под"
    @State private var street = ""
    @State private var comment = ""
    @State private var building = ""
    private var maxFirstNameCharachtersCount: Int = 12
    private var maxLastNameCharachtersCount: Int = 12
    private let maxBuildingCharachtersCount: Int = 8
    private let maxStreetCharachtersCount: Int = 44
    private let maxCommentCharachtersCount: Int = 91
    private let maxApartmentCharachtersCount: Int = 6
    private let maxEntranceCharachtersCount: Int = 3
    private let maxFloorCharachtersCount: Int = 3
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 10
    @State private var maxStreetCharactersTextOpacity: Double = 0
    @State private var apartment = ""
    @State private var entrance = ""
    @State private var floor = ""
    @State private var countryCode = ""
    @State private var phoneNumber = ""
    @State private var isPrivateHouse = false
    @State private var showStreetsView = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName
        case lastName
        case phoneNumber
    }
    
    var body: some View {
        let roomTypes = ["кв", "оф", "каб"]
        let entranceTypes = ["под", "вход"]
        
           
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    
                    Text("Новый клиент")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(Color.black)
                        .offset(y: 30)
                    Spacer()
                        .frame(height: 70)
                    
                    ZStack {
                        Color.white
                            .cornerRadius(12)
                        
                        VStack {
                            
                            TextField("Имя", text: $firstName)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .padding(.leading, 11)
                                .background(Color.clear)
                                .focused($focusedField, equals: .firstName)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .lastName
                                }
                                .onChange(of: firstName) { newValue in
                                    if newValue.count > maxFirstNameCharachtersCount { firstName = String(newValue.prefix(maxFirstNameCharachtersCount))
                                        
                                    }
                                }
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                                .padding(.leading, 11)
                                .padding(.trailing, 10)
                            
                            TextField("Фамилия (не обязательно)", text: $lastName)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .padding(.leading, 11)
                                .padding(.top, 5)
                                .background(Color.clear)
                                .onChange(of: lastName) { newValue in
                                    if newValue.count > maxLastNameCharachtersCount {
                                        lastName = String(newValue.prefix(maxLastNameCharachtersCount))
                                    }
                                }
                                .focused($focusedField, equals: .lastName)
                                .submitLabel(.done)
                                .onSubmit {
                                    hideKeyboard()
                                }
                            
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                        
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                    .padding(.vertical, 8)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .frame(height: 110, alignment: .center)
                    
                    Spacer()
                        .frame(height: 35)
                    
                    HStack {
                        Text("Адрес")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                    }
                    
                    ZStack {
                        Color.white
                        
                        HStack {
                            
                            Spacer()
                            TextEditor(text: $street)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .frame(width: 320)
                                .frame(minHeight: 20, maxHeight: 45)
                                .lineLimit(2, reservesSpace: false)
                                .minimumScaleFactor(0.6)
                                .multilineTextAlignment(.center)
                            //.onChange(of: street) { oldValue, newValue in
                                .onChange(of: street) { newValue in
                                    if newValue.count > maxStreetCharachtersCount {
                                        street = String(newValue.prefix(maxStreetCharachtersCount))
                                    }
                                    if street.count >= maxStreetCharachtersCount  {
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
                    .frame(height: 67)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 20)
                    
                    Text("максимум символов \(maxStreetCharachtersCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .opacity(maxStreetCharactersTextOpacity)
                    
                    Spacer()
                        .frame(height: 21)
                    
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
                                    if newValue.count > maxBuildingCharachtersCount {
                                        building = String(newValue.prefix(maxBuildingCharachtersCount))
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
                                    if newValue.count > maxApartmentCharachtersCount {
                                        apartment = String(newValue.prefix(maxApartmentCharachtersCount))
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
                                    if newValue.count > maxEntranceCharachtersCount {
                                        entrance = String(newValue.prefix(maxEntranceCharachtersCount))
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
                    
                    Spacer()
                        .frame(height: 21)
                    
                    HStack {
                        Text("Номер телефона")
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                        Spacer()
                    }
                    .padding(.horizontal, 21)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    HStack {
                        Text("+")
                            .font(.system(size: 30, weight: .regular, design: .default))
                        ZStack {
                            Color.white
                            TextField("7", text: $countryCode)
                                .font(.system(size: 23, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: countryCode) { newValue in
                                    if newValue.count > maxCountryCodeCharactersCount {
                                        countryCode = String(newValue.prefix(maxCountryCodeCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(10)
                        .frame(width: 58, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        
                        ZStack {
                            Color.white
                            TextField("", text: $phoneNumber)
                                .font(.system(size: 23, weight: .regular, design: .default))
                                .foregroundColor(.black)
                                .offset(x: 8)
                                .keyboardType(.numberPad)
                                .onChange(of: phoneNumber) { newValue in
                                    if newValue.count > maxPhoneNumberCharactersCount {
                                        phoneNumber = String(newValue.prefix(maxPhoneNumberCharactersCount))
                                    }
                                }
                        }
                        .cornerRadius(10)
                        .frame(width: 154, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    HStack {
                        Text("Коментарий")
                            .padding(.leading, 21)
                            .foregroundColor(Color.custom(.textTitleGray))
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .background(Color.clear)
                        Spacer()
                    }
                    
                    ZStack {
                        Color.white
                            TextEditor(text: $comment)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .padding(.horizontal, 16)
                                .frame(minHeight: 80, maxHeight: 100)
                                .lineLimit(2, reservesSpace: false)
                                .minimumScaleFactor(0.6)
                                .multilineTextAlignment(.leading)
                                .onChange(of: comment) { newValue in
                                    if newValue.count > maxCommentCharachtersCount {
                                        comment = String(newValue.prefix(maxCommentCharachtersCount))
                                    }
                                }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 16)
                    
                    
                    Spacer()
                        .frame(height: 30)
                    
                   
                    
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
    NewClientView()
}



