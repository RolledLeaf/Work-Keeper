import SwiftUI

struct CompleteTaskView: View {
    
    @StateObject var viewModel: CompleteTaskViewModel
    
    private let maxCommentCharactersCount: Int = 300
    private let maxContractAmountCharacters: Int = 7
    private let maxCostCharacters: Int = 7
    @State private var commentTextOpacity: Double = 0
    var onComplete: ((String, Double) -> Void)? = nil
    @Environment(\.dismiss)
    private var dismiss
    private var adaptiveCardRadius: CGFloat {
        DeviceLayout.cardRadius(for: UIScreen.main.bounds.width)
    }
    
    init(viewModel: CompleteTaskViewModel, onComplete: ((String, Double) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 3) {
                VStack {
                HStack {
                    Text("• ")
                        .font(.custom(Montserrat.black.rawValue, size: 20))
                        .foregroundStyle(Color.custom(.pitchBlack))
                    +
                    Text("ЗАВЕРШЕНИЕ ")
                        .font(.custom(Montserrat.black.rawValue, size: 20))
                        .foregroundStyle(Color.custom(.pitchBlack))
                    +
                    Text("ЗАДАНИЯ")
                        .font(.custom(Montserrat.regular.rawValue, size: 20))
                        .foregroundStyle(Color.custom(.pitchBlack))
                    +
                    Text(" •")
                        .font(.custom(Montserrat.black.rawValue, size: 20))
                        .foregroundStyle(Color.custom(.pitchBlack))
                }
                .frame(height: 22)
                .padding(.top, 23)
                
                //СТек коментария
                HStack {
                    Text("Комментарий")
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
                
                TextEditor(text: $viewModel.comment)
                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                        .foregroundStyle(Color.custom(.pitchBlack))
                        .padding(.horizontal, 12)
                        .frame(height: 80)
                        .multilineTextAlignment(.leading)
                        .scrollContentBackground(.hidden) // скрыть внутренний фон
                        .background(Color.custom(.pureWhite))
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
                .padding(.top, 7)
                Spacer()
                    .frame(height: 20)
            }
                .frame(height: 195)
            .background(
                RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                    .fill(Color.custom(.bckgFieldGray))
               
            )
            .overlay(
                RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight])
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            )
          

                
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
//                            .focused($focusedField, equals: .contractAmount)
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
            }
            .frame(height: 38)
            .padding(.horizontal, 4)
                
                
                HStack {
                    Text("Итого")
                        .font(.custom(Montserrat.bold.rawValue, size: 32))
                    
                    Text(String(viewModel.finalAmount.formattedCurrency()))
                        .font(.custom(SFPro.bold.rawValue, size: 32))
                }
                .padding(.top, 10)

              
                //Cancel/Complete HStack
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
                    
                    Button(action: {
                        viewModel.complete()
                        onComplete?(viewModel.taskDescription, viewModel.finalAmount)
                        dismiss()
                    }) {
                        ZStack {
                            Rectangle()
                                .tint(Color.custom(.taskCompleteGreen))
                            Text("Завершить")
                                .foregroundStyle(Color.custom(.mainBlack))
                            
                        }
                    }
                    .cornerRadius(30)
                    .frame(height: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                //End of Cancel/Complete HStack
                Spacer()
            }
        }
        //End global of ZStack
        
    }
    
}

