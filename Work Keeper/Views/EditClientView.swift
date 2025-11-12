import SwiftUI

struct EditClientView: View {
    
    @ObservedObject var viewModel: EditClientViewModel
    @StateObject var streetListViewModel = StreetListViewModel()
   
    @State private var roomType = "кв"
    @State private var entranceType = "под"

    private var maxFirstNameCharachtersCount: Int = 12
    private var maxLastNameCharachtersCount: Int = 12
    private let maxBuildingCharachtersCount: Int = 8
    private let maxStreetCharachtersCount: Int = 44
    private let maxCommentCharachtersCount: Int = 91
    private let maxApartmentCharachtersCount: Int = 6
    private let maxEntranceCharachtersCount: Int = 3
    private let maxFloorCharachtersCount: Int = 3
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 16
    @State private var phoneMasked: String = ""
    @State private var previousPhoneMasked: String = ""
    @State private var maxStreetCharactersTextOpacity: Double = 0
 
    @State private var showCreateClientAlert = false
    @State private var showStreetsView = false
    @FocusState private var focusedField: Field?
    
    private var onEdit: ((String) -> Void)?
    
    @Environment(\.dismiss)
    private var dismiss
    
    init(viewModel: EditClientViewModel, onEdit: ((String) -> Void)? = nil) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onEdit = onEdit
      }
    
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
            
           
                VStack {
                    
                    Text("Редактирование клиента")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(Color.black)
                        .offset(y: 30)
                    Spacer()
                        .frame(height: 70)
                    
                    ZStack {
                        Color.white
                            .cornerRadius(12)
                        
                        VStack {
                            
                            TextField("Имя", text: $viewModel.firstName)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .padding(.leading, 11)
                                .background(Color.clear)
                                .focused($focusedField, equals: .firstName)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .lastName
                                }
                                .onChange(of: viewModel.firstName) { newValue in
                                    if newValue.count > maxFirstNameCharachtersCount { viewModel.firstName = String(newValue.prefix(maxFirstNameCharachtersCount))
                                        
                                    }
                                }
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                                .padding(.leading, 11)
                                .padding(.trailing, 10)
                            
                            TextField("Фамилия (не обязательно)", text: $viewModel.lastName)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .padding(.leading, 11)
                                .padding(.top, 5)
                                .background(Color.clear)
                                .onChange(of: viewModel.lastName) { newValue in
                                    if newValue.count > maxLastNameCharachtersCount {
                                        viewModel.lastName = String(newValue.prefix(maxLastNameCharachtersCount))
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
                        
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    .padding(.vertical, 8)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .frame(height: 110, alignment: .center)
                    
                    Spacer()
                        .frame(height: 35)
                    
                    HStack {
                        Text("Улица")
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
                            TextEditor(text: $viewModel.streetName)
                                .font(.system(size: 20, weight: .regular, design: .default))
                                .frame(width: 320)
                                .frame(minHeight: 20, maxHeight: 45)
                                .lineLimit(2, reservesSpace: false)
                                .minimumScaleFactor(0.6)
                                .multilineTextAlignment(.center)
                            //.onChange(of: street) { oldValue, newValue in
                                .onChange(of: viewModel.streetName) { newValue in
                                    if newValue.count > maxStreetCharachtersCount {
                                        viewModel.streetName = String(newValue.prefix(maxStreetCharachtersCount))
                                    }
                                    if viewModel.streetName.count >= maxStreetCharachtersCount  {
                                        maxStreetCharactersTextOpacity = 1
                                    } else {
                                        maxStreetCharactersTextOpacity = 0
                                    }
                                }
                            
                            
                            
                            Spacer()
                            
                            Button(action: {
                                streetListViewModel.selectedStreet = nil
                                focusedField = nil
                                hideKeyboard()
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
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
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
                            TextField("", text: $viewModel.house)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: viewModel.house) { newValue in
                                    if newValue.count > maxBuildingCharachtersCount {
                                        viewModel.house = String(newValue.prefix(maxBuildingCharachtersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 75, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
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
                            TextField("", text: $viewModel.apartment)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: viewModel.apartment) { newValue in
                                    if newValue.count > maxApartmentCharachtersCount {
                                        viewModel.apartment = String(newValue.prefix(maxApartmentCharachtersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 66, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
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
                            TextField("", text: $viewModel.entrance)
                                .font(.system(size: 19, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .onChange(of: viewModel.entrance) { newValue in
                                    if newValue.count > maxEntranceCharachtersCount {
                                        viewModel.entrance = String(newValue.prefix(maxEntranceCharachtersCount))
                                    }
                                }
                        }
                        .cornerRadius(5)
                        .frame(width: 37, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
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
                            TextField("", text: $viewModel.floor)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 19, weight: .regular, design: .default))
                        }
                        .cornerRadius(5)
                        .frame(width: 40, height: 30)
                        
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        
                        Text("Только дом")
                            .font(.custom(SFPro.italic.rawValue, size: 20))
                            .padding(.horizontal)
                            .frame(width: 150)
                            .offset(x: 35)
                        
                        Toggle("", isOn: $viewModel.isPrivateHouse)
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
                        ZStack {
                            Color.white
                            TextField("+7", text: $phoneMasked)
                                .font(.system(size: 21, weight: .regular, design: .default))
                                .foregroundColor(.black)
                                .padding(.leading, 5)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                                .onChange(of: phoneMasked) { newValue in
                                    let prevDigits = digitsOnly(previousPhoneMasked)
                                    var newDigits  = digitsOnly(newValue)

                                    // Если удалили масочный символ, удалим ещё одну цифру вручную
                                    if newValue.count < previousPhoneMasked.count && newDigits.count == prevDigits.count {
                                        if !newDigits.isEmpty { newDigits.removeLast() }
                                    }

                                    // РФ нормализация: убрать ведущие 8/7 и ограничить до 10 цифр
                                    if newDigits.hasPrefix("8") { newDigits.removeFirst() }
                                    if newDigits.hasPrefix("7") { newDigits.removeFirst() }
                                    if newDigits.count > 10 { newDigits = String(newDigits.prefix(10)) }

                                    let masked = maskRU(fromDigits: newDigits) // +7(XXX)XXX-XX-XX
                                    if masked.count > maxPhoneNumberCharactersCount {
                                        phoneMasked = String(masked.prefix(maxPhoneNumberCharactersCount))
                                    } else {
                                        phoneMasked = masked
                                    }
                                    previousPhoneMasked = phoneMasked
                                    viewModel.phoneDigits = newDigits // в VM храним только цифры
                                }
                        }
                        .cornerRadius(10)
                        .frame(width: 190, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Spacer()
            
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
                            if viewModel.canUpdateClient() {
                                onEdit?(viewModel.firstName)
                                viewModel.update()
                                dismiss()
                            } else {
                                showCreateClientAlert = true
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(viewModel.canUpdateClient() ? .highlightBlue : .inactiveButtonGray))
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
                    .padding(.bottom, 10)
                
                } // end of main VStack
               
           
           
            }
        .onTapGesture {
            hideKeyboard()
        }
        
     .sheet(isPresented: $showStreetsView, onDismiss: {
         if let selected = streetListViewModel.selectedStreet {
             viewModel.streetName = selected.name ?? ""
         }
     }) {
         StreetsListView(viewModel: streetListViewModel)
     }

     .alert(isPresented: $showCreateClientAlert) {
         Alert(title: Text("Ошибка"), message: Text("Заполните Имя и телефон"), dismissButton: .default(Text("OK")))
     }
        .onAppear {
            phoneMasked = maskRU(fromDigits: viewModel.phoneDigits)
            previousPhoneMasked = phoneMasked
        }
    }
}


#Preview {
    NewClientView()
}




//# MARK: - Phone helpers
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
