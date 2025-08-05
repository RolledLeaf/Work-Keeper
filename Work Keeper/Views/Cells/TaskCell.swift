import SwiftUI


let defaultNumber = "1"

struct TaskRow: View {
    @State private var showPhoneNumberCloudLocal = false
    @State private var showRepeatClientBubbleLocal = false
    @State private var showPhoneNumberCloudRemote = false
    @State private var showRepeatClientBubbleRemote = false
    @State private var showCashIcon = false
    @State private var showCreditCardIcon = false
    @State private var repeatBadgeOpacity: Double = 0
    @State private var creditCardOpacity: Double = 0
    @State private var cashOpacity: Double = 0
    @State var viewModel = TaskListViewModel()
    
 
    var clientTasksCount: Int {
        guard let tasks = task.client?.tasks as? Set<Task> else { return 0 }
        return tasks.count
    }
    
  
    let task: Task
    
    var body: some View {
        
        let statusColor: CustomColor
        
        switch task.status {
        case .scheduled:
            statusColor = .taskViewYellow
        case .completed:
            statusColor = .taskCompleteGreen
        case .canceled:
            statusColor = .taskCanceledOrange
        }
        
        return VStack {
            HStack{
                Color.custom(statusColor)
                    .frame(width: 6)
                    .frame(maxHeight: .infinity)
                    .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                    .offset(x: 5)
                    .padding(.top, 10)
                if task.isRemote == false {
                    VStack {
                        HStack {
                            Text(task.scheduledAt?.formattedAsTime() ?? "\(date1)") //Некрасиво развёрнут опционал даты
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 5)
                            
                          
                                ZStack {
                                    Image("repeatClientCloud")

                                    Text("Клиент\nрепит")
                                        .font(.custom(SFPro.regular.rawValue, size: 12))
                                        .multilineTextAlignment(.center)
                                        .offset(x: -4)
                                        
                                }
                                .frame(width: 20)
                                .offset(x: -8, y: 2)
                                .opacity(showRepeatClientBubbleLocal ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: showRepeatClientBubbleLocal)
                            
                               
                            
                                Button(action: {
                                    showRepeatClientBubbleLocal = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showRepeatClientBubbleLocal = false
                                        }
                                    }
                                }) {
                                    Image("repeatBadge")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(6)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .contentShape(Circle())
                                .opacity(repeatBadgeOpacity)
                                .onAppear {
                                    repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
                                }
                            
                                Text(task.client?.firstName ?? "")
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            
                            Spacer()
                            
                            ZStack {
                                Image("phoneNumberCloud")
                                Text("\(task.client?.phone ?? "")")
                                    .font(.custom(SFPro.regular.rawValue, size: 12))
                                    .offset(x: -3)
                                    .onTapGesture {
                                        if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                              UIApplication.shared.canOpenURL(url) {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                            }
                          
                            .padding(.leading, -70)
                            .offset(x: 11)
                            .opacity(showPhoneNumberCloudLocal ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudLocal)
                            Button(action: {
                                showPhoneNumberCloudLocal = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showPhoneNumberCloudLocal = false
                                    }
                                }
                            }) {
                                Image("call")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                            }
                            .contentShape(Rectangle())
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.trailing, 5)
                        .frame(maxHeight: 35)
                        
                        Text("\(task.client?.primaryAddress?.street?.name ?? "Адрес не указан") \(task.client?.primaryAddress?.house ?? "")")
                            .font(.custom(SFPro.regular.rawValue, size: 27))
                            .foregroundColor(.custom(.taskTextGray))
                            .frame(maxHeight: 46)
                            .padding(.leading, 0)
                            .frame(width: 320, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.7)
                        if task.client?.primaryAddress?.isPrivateHouse == false {
                            HStack {
                                
                                Image("location")
                                    .offset(x: -9, y: -9)
                                Spacer()
                                Text("\(task.client?.primaryAddress?.roomType ?? "кв.") \(task.client?.primaryAddress?.apartment ?? defaultNumber)")
                                    .foregroundColor(.custom(.taskTextGray))
                                Spacer()
                                Text("\(task.client?.primaryAddress?.entranceType ?? "под.") \(task.client?.primaryAddress?.entrance ?? defaultNumber)")
                                    .foregroundColor(.custom(.taskTextGray))
                                Spacer()
                                Text("эт. \(task.client?.primaryAddress?.floor ?? "")")
                                    .foregroundColor(.custom(.taskTextGray))
                            }
                            .padding(.trailing, 90)
                            .padding(.leading, 15)
                            } else {
                                HStack {
                                Image("location")
                                    .offset(y: -9)
                                
                                Spacer()
                                Text("(Частный дом)")
                                    .font(.custom(SFPro.italic.rawValue, size: 20))
                                    .foregroundColor(.custom(.taskTextGray))
                                    .offset(x: -19)
                            }
                                .padding(.trailing, 90)
                                .padding(.leading, 10)
                        }
                       
                        
                        
                        Rectangle()
                            .frame( height: 0.5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .padding(.top, -15)
                        
                        Text(task.taskDescription ?? "")
                            .font(.custom(SFPro.regular.rawValue, size: 22))
                            .bold()
                            .frame(maxWidth: 355, alignment: .center)
                            .frame(height: 40)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.65)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .padding(.top, -15)
                            .padding(.bottom, 5)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack {
                        HStack {
                            Text(task.scheduledAt?.formattedAsTime() ?? "\(date1)") //Некрасиво развёрнут опционал даты
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 5)
                            
                          
                                ZStack {
                                    Image("repeatClientCloud")

                                    Text("Клиент\nрепит")
                                        .font(.custom(SFPro.regular.rawValue, size: 12))
                                        .multilineTextAlignment(.center)
                                        .offset(x: -4)
                                        
                                }
                                .frame(width: 20)
                                .offset(x: -8, y: 2)
                                .opacity(showRepeatClientBubbleLocal ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: showRepeatClientBubbleLocal)
                            
                               
                            
                                Button(action: {
                                    showRepeatClientBubbleLocal = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showRepeatClientBubbleLocal = false
                                        }
                                    }
                                }) {
                                    Image("repeatBadge")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(6)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .contentShape(Circle())
                                .opacity(repeatBadgeOpacity)
                                .onAppear {
                                    repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
                                }
                            
                                Text(task.client?.firstName ?? "")
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            
                            Spacer()
                            
                            ZStack {
                                Image("phoneNumberCloud")
                                Text("\(task.client?.phone ?? "")")
                                    .font(.custom(SFPro.regular.rawValue, size: 12))
                                    .offset(x: -3)
                                    .onTapGesture {
                                        if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                              UIApplication.shared.canOpenURL(url) {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                            }
                          
                            .padding(.leading, -70)
                            .offset(x: 11)
                            .opacity(showPhoneNumberCloudLocal ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudLocal)
                            Button(action: {
                                showPhoneNumberCloudLocal = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showPhoneNumberCloudLocal = false
                                    }
                                }
                            }) {
                                Image("call")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                            }
                            .contentShape(Rectangle())
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.trailing, 5)
                        .frame(maxHeight: 35)

                        HStack{
                               Image("remote")
                                .offset(y: -2)
                               Spacer()
                       
                               Text("Удалёнка")
                                   .font(.custom(SFPro.regular.rawValue, size: 27))
                                   .foregroundColor(.custom(.taskTextGray))
                                   .offset(x: 10)
                           }
                        .frame(height: 23)
                        .padding(.trailing, 125)
                        .padding(.leading, 8)
                        
                        
                        Rectangle()
                            .frame( height: 0.5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            
                        
                        Text(task.taskDescription ?? "")
                            .font(.custom(SFPro.bold.rawValue, size: 30))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(maxHeight: 40)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                            
                    }
                    .frame(maxHeight: .infinity)
                }
                    
            }
            .frame(maxHeight: .infinity)

            VStack{
                Rectangle()
                    .frame( height: 0.5)
                    .frame(maxWidth: .infinity)
                    
                
                HStack{
                    Text("Договорились:  \(task.contractAmount.formattedCurrency())")
                        .font(.custom(SFPro.bold.rawValue, size: 17))
                    
                    Spacer()
                    
                    Text("Итого:")
                        .font(.custom(SFPro.bold.rawValue, size: 19))
                    Image("creditCard")
                        .opacity(creditCardOpacity)
                }
                .padding(.leading, 32)
                .padding(.trailing, 8)
                .frame(maxHeight: 12)
                
                HStack{
                    Text("Издержки:")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    Text("\(task.cost.formattedCurrency())")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .foregroundColor(Color.custom(.costPaymentRed))
                    
                    Text("Доплачено:")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    Text("\(task.extraPayment.formattedCurrency())")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .foregroundColor(Color.custom(.extraPaymentGreen))
                    
                    Spacer()
                    
                    Text("\(task.totalAmount.formattedCurrency())")
                        .font(.custom(SFPro.bold.rawValue, size: 16))
                    Image("cash")
                        .opacity(cashOpacity)
                        .onAppear {
                            updatePaymentIcons()
                        }
                        .onChange(of: task.paymentType ?? "") { _ in
                            updatePaymentIcons()
                        }
                }
                .frame(maxHeight: 12)
                .padding(.leading, 11)
                .padding(.trailing, 8)
                .padding(.top, 0)
            }
            .frame(maxHeight: 55)
            .padding(.top, -10)
        }
        .background(Color.custom(.taskCellGray))
        .cornerRadius(12)
        
        
    }
       
}


#Preview {
    TaskListView()
}

    


// MARK: - Payment Icon Logic
private extension TaskRow {
    func updatePaymentIcons() {
        if task.paymentType == PaymentType.cash.rawValue {
            cashOpacity = 1
            creditCardOpacity = 0
        } else if task.paymentType == PaymentType.transfer.rawValue {
            cashOpacity = 0
            creditCardOpacity = 1
        } else {
            cashOpacity = 0
            creditCardOpacity = 0
        }
    }
}
