

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
    private let maxAddressNoteCharactersCount: Int = 72
    private let maxApartmentCharactersCount: Int = 6
    private let maxEntranceCharactersCount: Int = 4
    private let maxFloorCharactersCount: Int = 4
    private let maxPhoneNumberCharactersCount: Int = 20
    private let maxContractAmountCharacters: Int = 7
    private let maxCostCharacters: Int = 7
    private let maxFloorCharacters: Int = 4
    private let addressUnitsPadding: CGFloat = 4
    
    @State private var phoneMasked: String = ""
    @State private var previousPhoneMasked: String = ""
    @State private var alertMessage: String = "Заполните обязательные поля"
    
    @State private var streetCharactersTextOpacity: Double = 0
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
    
    
    private var adaptiveCardRadius: CGFloat {
        DeviceLayout.cardRadius(for: UIScreen.main.bounds.width)
    }

    private var smallPhoneFontSize: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 13 : 15
    }
   
    
    init(onComplete: ((String) -> Void)? = nil) {
        
        self.onComplete = onComplete
    }
    
    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
    
    enum Field {
        case house
        case apartment
        case entrance
        case floor
        case contractAmount
    }
    
    func clearAllFields() {
        viewModel.description = ""
        viewModel.firstName = ""
        viewModel.phoneDigits = ""
        viewModel.streetName = ""
        viewModel.house = ""
        viewModel.apartment = ""
        viewModel.entrance = ""
        viewModel.floor = ""
        viewModel.contractAmountText = ""
        viewModel.costText = ""
        viewModel.isRemote = false
        viewModel.isPrivateHouse = false
        viewModel.scheduledAt = Date()
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
                // Start of main VStack
                VStack(spacing: 3) {
                    VStack  {
                        HStack {
                            Text("• ")
                                .font(.custom(Montserrat.black.rawValue, size: 20))
                                .foregroundStyle(Color.custom(.pitchBlack))
                            +
                            Text("НОВОЕ ")
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
                            
                            TextEditor(text: $viewModel.description)
                            
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 12)
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
                    .padding(.top, 1)
                    .padding(.horizontal, 4)
                    
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
                    .padding(.top, 7)
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
                                .frame(width: 11)
                            
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
                    .padding(.top, 7)
                    
                    //address section begings
                    VStack(spacing: 4) {
                        Spacer()
                                .frame(height: 20)
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
                            Color.custom(viewModel.isRemote || viewModel.isAtMyPlace ? .inactiveFiledGray : .pureWhite)
                            HStack {
                                TextEditor(text: $viewModel.streetName)
                                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                                    .frame(height: 40, alignment: .center)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .disabled(viewModel.remoteEditingBlock || viewModel.isAtMyPlace)
                                    .scrollContentBackground(.hidden)
                                    .onChange(of: viewModel.streetName) { _, newValue in
                                        if newValue.count > maxStreetCharactersCount {
                                            viewModel.streetName = String(newValue.prefix(maxStreetCharactersCount))
                                        }
                                        if viewModel.streetName.count >= maxStreetCharactersCount  {
                                            streetCharactersTextOpacity = 1
                                        } else {
                                            streetCharactersTextOpacity = 0
                                        }
                                    }
                                    .offset(y: 2)
                                
                                Spacer()
                                
                                Button(action: {
                                    showStreetsView = true
                                }) {
                                    Image("chevronRight")
                                        .opacity(viewModel.isRemote || viewModel.isAtMyPlace ? 0 : 1)
                                        .frame(width: 12, height: 6.61)
                                }
                                .tint(Color.custom(.pitchBlack))
                                .disabled(viewModel.remoteEditingBlock || viewModel.isAtMyPlace)
                                
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
                    
                        //дом квартира падик секция - начало
                        GeometryReader { geo in
                            let total = geo.size.width
                            let gap: CGFloat = 4
                            let available = max(0, total - gap)
                            let firstW = available * (1.0 / 3.0)
                            let secondW = available * (2.0 / 3.0)

                            HStack(spacing: gap) {

                                // Первый вертикальный стек - начало (дом/этаж)
                                VStack(spacing: 10) {
                                    HStack(spacing: 6) {

                                        Text("дом")
                                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                                            .foregroundStyle(Color.custom(.textTitleGray))
                                            .padding(.leading, 13)

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
                                            .disabled(viewModel.isRemote || viewModel.isAtMyPlace)

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
                                            .fill(Color.custom(viewModel.isRemote || viewModel.isAtMyPlace ? .inactiveFiledGray : .pureWhite))
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
                                        TextField("", text: $viewModel.floor)
                                            .multilineTextAlignment(.center)
                                            .disabled(viewModel.isRemote || viewModel.isPrivateHouse || viewModel.isAtMyPlace)
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
                                    .frame(height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 30)
                                            .fill(Color.custom(viewModel.isRemote || viewModel.isAtMyPlace || viewModel.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                    )

                                }
                                .frame(width: firstW, alignment: .leading)

                                // Второй вертикальный стек - начало (кв/подъезд/тоггл)
                                VStack {
                                    HStack(spacing: 4) {
                                        HStack(spacing: 6) {

                                            Menu {
                                                ForEach(viewModel.roomTypes, id: \.self) { type in
                                                    Button(type) {
                                                        viewModel.roomType = type
                                                    }

                                                }
                                            } label: {
                                                HStack(spacing: 1) {
                                                    Text(viewModel.roomType)
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
                                            .disabled(viewModel.isRemote || viewModel.isPrivateHouse || viewModel.isAtMyPlace)

                                            Image("deviderVertical")


                                            TextField("", text: $viewModel.apartment)
                                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                                .foregroundStyle(Color.custom(.pitchBlack))
                                                .multilineTextAlignment(.center)
                                                .disabled(viewModel.isRemote || viewModel.isPrivateHouse || viewModel.isAtMyPlace)
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
                                                .fill(Color.custom(viewModel.isRemote || viewModel.isAtMyPlace || viewModel.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                        )

                                        HStack(spacing: 6) {

                                            Menu {
                                                ForEach(viewModel.entranceTypes, id: \.self) { type in
                                                    Button(type) {
                                                        viewModel.entranceType = type
                                                    }
                                                }
                                            } label: {
                                                HStack(spacing: 1) {
                                                    Text(viewModel.entranceType)
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
                                            .disabled(viewModel.isRemote || viewModel.isPrivateHouse || viewModel.isAtMyPlace)

                                            Image("deviderVertical")
                                                .padding(.leading, 2)

                                            TextField("", text: $viewModel.entrance)
                                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                                .foregroundStyle(Color.custom(.pitchBlack))
                                                .multilineTextAlignment(.center)
                                                .disabled(viewModel.isRemote || viewModel.isPrivateHouse || viewModel.isAtMyPlace)
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
                                                .fill(Color.custom(viewModel.isRemote || viewModel.isAtMyPlace || viewModel.isPrivateHouse ? .inactiveFiledGray : .pureWhite))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                        )
                                    }

                                    Spacer()

                                    HStack {
                                        Spacer()
                                        Toggle(isOn: $viewModel.isAtMyPlace) {
                                            HStack {
                                                Spacer()
                                                Text("У себя")
                                                    .font(.custom(Montserrat.regular.rawValue, size: smallPhoneFontSize))
                                                    .foregroundStyle(Color.custom(.pitchBlack))
                                            }
                                        }
                                        .tint(Color.custom(.taskCompleteGreen))
                                        .frame(alignment: .leading)
                                        .disabled(viewModel.isPrivateHouse || viewModel.isRemote)
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
                                    }

                                }
                                .frame(width: secondW, alignment: .leading)

                            }
                        }
                        .frame(height: 90)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    //Дом кв падик секция - конец
                    
 
                        HStack(spacing: 2) {
                        Toggle(isOn: $viewModel.isPrivateHouse) {
                            HStack {
                                Spacer()
                                Text("Только дом")
                                    .font(.custom(Montserrat.regular.rawValue, size: smallPhoneFontSize))
                                    .foregroundStyle(Color.custom(.pitchBlack))
                            }
                        }
                        .tint(Color.custom(.taskCompleteGreen))
                        .frame(alignment: .leading)
                        .disabled(viewModel.shouldBlockPrivate || viewModel.isAtMyPlace)
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
                            HStack {
                                Spacer()
                                Text("Удалённо")
                                    .font(.custom(Montserrat.regular.rawValue, size: smallPhoneFontSize))
                                    .frame(alignment: .trailing)
                                    .foregroundStyle(Color.custom(.pitchBlack))
                            }
                        }
                        .tint(Color.custom(.taskCompleteGreen))
                        .disabled(viewModel.shouldBlockRemote || viewModel.isAtMyPlace)
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
                    .padding(.top, 13)
                    .padding(.leading, 20)
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
                            Color.custom(viewModel.isRemote || viewModel.isAtMyPlace ? .inactiveFiledGray : .pureWhite)
                            
                            TextEditor(text: $viewModel.addressNote)
                            
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .padding(.horizontal, 12)
                                .frame(height: 60)
                                .disabled(viewModel.isRemote || viewModel.isAtMyPlace)
                                .multilineTextAlignment(.leading)
                                .scrollContentBackground(.hidden) // скрыть внутренний фон
                                .onChange(of: viewModel.addressNote) { newValue in
                                    if newValue.count > maxAddressNoteCharactersCount {
                                        viewModel.addressNote = String(newValue.prefix(maxAddressNoteCharactersCount))
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
                                .frame(height: 20)

                    
                }
                    .frame(maxHeight: 450)
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
                            Text("ИТОГО:")
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
                            clearAllFields()
                        }) {
                            ZStack {
                                Rectangle()
                                    .tint(Color.custom(.taskCanceledOrange))
                                Text("Очистить")
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
                                clearAllFields()
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
                    .padding(.top, 15)
                    
                    Spacer()
                        .frame(height: 20)
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
            print("width:", UIScreen.main.bounds.width)
            phoneMasked = maskRU(fromDigits: viewModel.phoneDigits)
            previousPhoneMasked = phoneMasked

            // Inject sync dependencies (if user is logged in)
            if let ownerId = auth.session?.user.id {
                viewModel.configureSync(syncService: syncService, ownerId: ownerId)
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
