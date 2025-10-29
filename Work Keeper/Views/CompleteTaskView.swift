import SwiftUI

struct CompleteTaskView: View {
    
    @ObservedObject var viewModel: CompleteTaskViewModel
    
    private let maxCommentCharactersCount: Int = 300
    @State private var commentTextOpacity: Double = 0
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
           
                Text("Завершение задания")
                    .font(.custom(SFPro.regular.rawValue, size: 36))
                    .padding(.top, 20)
                
                Spacer()
                    .frame(height: 48)
                
                HStack {
                    Text("Коментарий")
                        .padding(.leading, 21)
                        .foregroundColor(Color.custom(.textTitleGray))
                        .font(.system(size: 24, weight: .regular, design: .default))
                        .background(Color.clear)
                    
                    Spacer()
                }
                ZStack {
                    Color.white
                
                TextEditor(text: $viewModel.comment)
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .frame(width: 320)
                    .frame(height: 130)
                    .lineLimit(1, reservesSpace: false)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .onChange(of: viewModel.comment) { newValue in
                        if newValue.count > maxCommentCharactersCount {
                            viewModel.comment = String(newValue.prefix(maxCommentCharactersCount))
                        }
                        if viewModel.comment.count >= maxCommentCharactersCount {
                            commentTextOpacity = 1
                        } else {
                            commentTextOpacity = 0
                        }
                    }
            }
            .frame(height: 130)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            )
            .padding(.horizontal, 20)
                
                Text("максимум символов \(maxCommentCharactersCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .opacity(commentTextOpacity)
                
               
                
                Spacer()
                    .frame(height: 31)
                
                HStack {
                    Text("Договорились")
                        .padding(.leading, 21)
                        .foregroundColor(Color(.black))
                        .font(.system(size: 19, weight: .regular, design: .default))
                        .background(Color.clear)
                    Spacer()
                    
                    TextField("", text: $viewModel.contractAmountText)
                        .font(.system(size: 19, weight: .regular, design: .default))
                        .frame(width: 100, height: 30)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .onChange(of: viewModel.contractAmountText) { newValue in
                            if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                viewModel.contractAmount = value
                            } else {
                                viewModel.contractAmount = 0
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                .fill(Color.white)
                        )
                }
                .padding(.trailing, 48)
                
                Spacer()
                    .frame(height: 34)
                
                
                
                HStack {
                    Text("Издержки")
                        .padding(.leading, 21)
                        .foregroundColor(Color(.black))
                        .font(.system(size: 19, weight: .regular, design: .default))
                        .background(Color.clear)
                    Spacer()
                    
                    TextField("", text: $viewModel.costText)
                        .font(.system(size: 19, weight: .regular, design: .default))
                        .frame(width: 100, height: 30)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.costText) { newValue in
                            if let value = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                                viewModel.cost = value
                            } else {
                                viewModel.cost = 0
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                .fill(Color.white)
                        )
                }
                .padding(.trailing, 48)
                
                Spacer()
                    .frame(height: 34)
                
                
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
                            } else {
                                viewModel.extraPayment = 0
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
                                .fill(Color.white)
                        )
                }
                .padding(.trailing, 48)
                
                Picker("Тип оплаты", selection: $viewModel.paymentType) {
                    Text("Наличные").tag(PaymentType.cash)
                    Text("Перевод").tag(PaymentType.transfer)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
          
            
                
                Spacer()
                    
                
                HStack {
                    Text("Итого")
                        .font(.custom(SFPro.bold.rawValue, size: 32))
                    
                    Text(String(viewModel.finalAmount.formattedCurrency()))
                        .font(.custom(SFPro.bold.rawValue, size: 32))
                }

              
                
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
                        viewModel.complete()
                        dismiss()
                    }) {
                        ZStack {
                            Rectangle()
                                .tint(Color.black)
                            Text("Завершить")
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
            }
        }
        
        
    } //End global of ZStack
    
}

