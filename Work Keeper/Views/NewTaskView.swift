

import SwiftUI

struct DatePickerField: View {
    @Binding var date: Date
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formattedAsDate())
                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                    .foregroundStyle(.pitchBlack)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.custom(.bckgFieldGray))
            )
            
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            )
        }
    }
}

struct TimePickerField: View {
    @Binding var date: Date
    var minuteInterval: Int = 5
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.formattedAsTime())
                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                    .foregroundStyle(.pitchBlack)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.custom(.bckgFieldGray))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            )
        }
    }
}

struct DatePickerView: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Дата")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                Spacer()
                Button("Готово") {
                    isPresented = false
                }
                .font(.custom(Montserrat.semibold.rawValue, size: 17))
            }
            .padding()
            
            IntervalDatePicker(
                date: $date,
                components: [.date],
                minuteInterval: 5
            )
            .labelsHidden()
            .frame(maxHeight: 250)
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }
}

struct TimePickerView: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Время")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                Spacer()
                Button("Готово") {
                    isPresented = false
                }
                .font(.custom(Montserrat.semibold.rawValue, size: 17))
            }
            .padding()
            
            IntervalDatePicker(
                date: $date,
                components: [.hourAndMinute],
                minuteInterval: 5
            )
            .labelsHidden()
            .frame(maxHeight: 250)
            .padding(.horizontal)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }
}



struct IntervalDatePicker: UIViewRepresentable {
    @Binding var date: Date
    var components: DatePickerComponents
    var minuteInterval: Int = 5
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        
        switch components {
            
        case [.date]:
            picker.datePickerMode = .date
        case [.hourAndMinute]:
            picker.datePickerMode = .time
            
        default:
            picker.datePickerMode = .dateAndTime
        }
        
        picker.minuteInterval = minuteInterval
        picker.preferredDatePickerStyle = .wheels
        picker.date = date
        picker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        if uiView.date != date {
            uiView.date = date
        }
        
        if uiView.minuteInterval != minuteInterval {
            uiView.minuteInterval = minuteInterval
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject {
        var parent: IntervalDatePicker
        
        init(parent: IntervalDatePicker) {
            self.parent = parent
        }
        
        @objc func valueChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}

struct NewTaskView: View {
    
    
    @StateObject private var viewModel = CreateTaskViewModel()
    @StateObject private var clientsListViewModel = ClientsListViewModel()
    @StateObject private var streetListViewModel = StreetListViewModel()
    var onComplete: ((String) -> Void)? = nil
    
    
    private var maxFirstNameCharactersCount: Int = 13
    private let maxBuildingCharactersCount: Int = 9
    private let maxStreetCharactersCount: Int = 49
    private let maxDescriptionCharactersCount: Int = 85
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 4
    private let maxFloorCharactersCount: Int = 4
    private let maxCountryCodeCharactersCount: Int = 3
    private let maxPhoneNumberCharactersCount: Int = 20
    private let maxContractAmountCharacters: Int = 7
    private let maxCostCharacters: Int = 7
    private let maxFloorCharacters: Int = 4
    
    @State private var phoneMasked: String = ""
    @State private var previousPhoneMasked: String = ""
    @State private var alertMessage: String = "Заполните обязательные поля"
    
    @State private var StreetCharactersTextOpacity: Double = 0
    @State private var streetChevronOpacity: Double = 1
    @State private var showStreetsView = false
    @State private var showClientListToPickView = false
    @State private var isDatePickerPresented = false
    @State private var isTimePickerPresented = false
    @State private var hideScrollContentBackground = false
    @State private var streetTextFieldColor: CustomColor = .pureWhite
    @State private var houseTextFieldColor: CustomColor = .pureWhite
    @State private var textFieldColor: CustomColor = .pureWhite
    @State private var showNewTaskAlert = false
    @FocusState private var focusedField: Field?
   
    
    init(onComplete: ((String) -> Void)? = nil) {
        
        self.onComplete = onComplete
    }
    
    @Environment(\.dismiss)
    private var dismiss
    
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
    
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            ScrollView {

                VStack {
                    VStack  {
                        HStack {
                            Text("• НОВОЕ ")
                                .font(.custom(Montserrat.bold.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("ЗАДАНИЕ •")
                                .font(.custom(Montserrat.regular.rawValue, size: 20))
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
                            
                            TextEditor(text: $viewModel.description)
                            
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 16)
                                .frame(height: 80)
                                .multilineTextAlignment(.leading)
                                .scrollContentBackground(.hidden) // скрыть внутренний фон
                                .background(Color.custom(.pureWhite))
                                .onChange(of: viewModel.description) { newValue in
                                    if newValue.count > maxDescriptionCharactersCount {
                                        viewModel.description = String(newValue.prefix(maxDescriptionCharactersCount))
                                    }
           
                                }
                            
                        }
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                        )
                        
                        .padding(.horizontal, 24)
                        .padding(.top, 7)
                        
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .background(
                        RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight])
                            .fill(Color.custom(.bckgFieldGray))
                    )
                    .overlay(
                        RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                    )
                    
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
                    .padding(.top, 10)
                    .padding(.horizontal, 24)
                    
                    VStack { // Начало, клиент и телефон
                        HStack {
                            Text("Клиент")
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .background(Color.clear)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .frame(height: 12)
                            
                            Spacer()
                            
                            Text("Контакт")
                               
                                .foregroundColor(Color.custom(.textTitleGray))
                                .font(.custom(Montserrat.regular.rawValue, size: 12))
                                .background(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .frame(height: 12)
                            
                        }
                        .padding(.top, 16)
                        .padding(.leading, 36)
                        .padding(.trailing, 69)
                        
                        HStack {
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
                                        ZStack {
                                            Circle()
                                                .tint(Color.custom(.bckgFieldGray))
                                            
                                            Image("clientsActive")
                                                .resizable()
                                                .frame(width: 14, height: 14)
                                                .tint(Color.custom(.pitchBlack))
                                        }
                                    }
                                    
                                    .frame(height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                    )
                                    .padding(.trailing, 5)
                                }
                                
                            }
                            .cornerRadius(60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 60)
                                
                                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                            )
                           
                            .frame(height: 40, alignment: .center)
                            
                            Spacer()
                            
                            HStack {
                                
                                ZStack {
                                    Color.custom(.pureWhite)
                                    TextField("", text: $viewModel.phoneDigits)
                                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                                        .foregroundColor(.custom(.pitchBlack))
                                        .padding(.leading, 16)
                                        .keyboardType(.phonePad)
                                        .textContentType(.telephoneNumber)
                                        .onChange(of: viewModel.phoneDigits) { newValue in
                                            if newValue.count > maxPhoneNumberCharactersCount { viewModel.phoneDigits = String(newValue.prefix(maxPhoneNumberCharactersCount))
                                                
                                            }
                                        }
//
                                }
                                .cornerRadius(60)
                                
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 60)
                                        .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                )
                                
                            }
                            
                            
                        }
                        .frame(height: 40)
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
                            .frame(height: 40)
                            .padding(.trailing, 10)
                            .padding(.leading, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(  Color.custom(streetTextFieldColor))
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
                            .frame(width: 106, height: 40)
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
                        .frame(width: 165, alignment: .leading)
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
                        .frame(width: 148, alignment: .trailing)
                        
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
                        .padding(.leading, 36)
                    }
                    .frame(height: 161)
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
                            if let message = missingRequiredFieldsMessage() {
                                alertMessage = message
                                showNewTaskAlert = true
                            } else {
                                viewModel.saveTask()
                                onComplete?(viewModel.description)
                                dismiss()
                            }
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.taskCompleteGreen))
                                Text("Cоздать")
                                    .foregroundStyle(Color.custom(.mainBlack))
                                
                            }
                        }
                        .cornerRadius(30)
                        .frame(height: 60)
                        .opacity(viewModel.canSaveTask() ? 1 : 0.5)
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
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
        
        
        
        
        .alert(isPresented: $showNewTaskAlert) {
            Alert(
                title: Text("Зполните обязательные поля"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        
        
        .onAppear {
            phoneMasked = maskRU(fromDigits: viewModel.phoneDigits)
            previousPhoneMasked = phoneMasked
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
   
                if clientsListViewModel.didPickNewAddress {
                    viewModel.streetName = ""
                    viewModel.house = ""
                    viewModel.apartment = ""
                    viewModel.entrance = ""
                    viewModel.floor = ""
                    viewModel.isPrivateHouse = false

                    // сбрасываем флаг, чтобы не влиял на следующий выбор
                    clientsListViewModel.didPickNewAddress = false
                    clientsListViewModel.pickedAddress = nil
                    return
                }
                let chosenAddress: Address? = {
                    if let picked = clientsListViewModel.pickedAddress {
                        return picked
                    }
                    
                    return (selectedClient.address as? Set<Address>)?.first(where: { $0.isPrimary })
                }()

                if let address = chosenAddress {
                    viewModel.streetName = address.street?.name ?? ""
                    viewModel.house = address.house ?? ""
                    viewModel.apartment = address.apartment ?? ""
                    viewModel.entrance = address.entrance ?? ""
                    viewModel.floor = address.floor ?? ""
                    viewModel.isPrivateHouse = address.isPrivateHouse
                } else {
                    // Если адресов нет — очищаем поля
                    viewModel.streetName = ""
                    viewModel.house = ""
                    viewModel.apartment = ""
                    viewModel.entrance = ""
                    viewModel.floor = ""
                    viewModel.isPrivateHouse = false
                }
                clientsListViewModel.pickedAddress = nil
            }
        }) {
            ClientListToPickView(viewModel: clientsListViewModel)
        }
    }
    
    // Приводит телефон к маске "+7(XXX)XXX-XX-XX" (Россия) из любого ввода
    private func formatPhoneMaskedRU(_ raw: String) -> String {
        var s = digitsOnly(raw)
        if s.hasPrefix("8") { s.removeFirst() }
        if s.hasPrefix("7") { s.removeFirst() }
        if s.count > 10 { s = String(s.prefix(10)) }
        return maskRU(fromDigits: s)
    }
    
    // Оставляет только цифры из строки
    private func digitsOnly(_ s: String) -> String {
        return String(s.filter { $0.isNumber })
    }
    
    // Формирует маску "+7(XXX)XXX-XX-XX" из 0...10 цифр (только цифры)
    private func maskRU(fromDigits s: String) -> String {
        if s.isEmpty { return "" }
        var result = "+7"
        let chars = Array(s)
        
        result += " "
        let a = min(3, chars.count)
        result += String(chars[0..<a])
        if chars.count < 3 { return result }
        
        result += " "
        let b = min(3, chars.count - 3)
        if b > 0 { result += String(chars[3..<(3 + b)]) }
        if chars.count < 6 { return result }
        
        result += " "
        let c = min(2, chars.count - 6)
        if c > 0 { result += String(chars[6..<(6 + c)]) }
        if chars.count < 8 { return result }
        
        result += " "
        let d = min(2, chars.count - 8)
        if d > 0 { result += String(chars[8..<(8 + d)]) }
        
        return result
    }
}


#Preview {
    NewTaskView()
}
