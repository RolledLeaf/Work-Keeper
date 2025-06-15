import SwiftUI


let defaultNumber = "1"

struct TaskRow: View {
    @State private var showPhoneNumberCloudLocal = false
    @State private var showRepeatClientBubbleLocal = false
    @State private var showPhoneNumberCloudRemote = false
    @State private var showRepeatClientBubbleRemote = false
    @State private var showCashIcon = false
    @State private var showCreditCardIcon = false
    
    let task: Task
    
    var body: some View {
        
        let statusColor: CustomColor
        
        switch task.isCompleted {
        case .scheduled:
            statusColor = .taskInProgressYellow
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
                            Text(task.scheduledAt.formattedAsTime())
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 5)
                            
                            Spacer()
                            
                            //Стек имени
                            HStack {
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
                                Text(task.client.firstName)
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            }
                            .padding(.trailing, 35)
                            Spacer()
                            ZStack {
                                Image("phoneNumberCloud")
                                Text("\(task.client.phoneNumber)")
                                    .font(.custom(SFPro.regular.rawValue, size: 12))
                                    .offset(x: -3)
                                    .onTapGesture {
                                           if let url = URL(string: "tel://\(task.client.phoneNumber)"),
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
                        
                        Text("\(task.client.address.street) \(task.client.address.houseNumber)")
                            .font(.custom(SFPro.regular.rawValue, size: 27))
                            .foregroundColor(.custom(.taskTextGray))
                            .frame(maxHeight: 46)
                            .padding(.leading, 0)
                            .frame(width: 320, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.7)
                        if task.client.address.isPrivateHouse == false {
                            HStack {
                                
                                Image("location")
                                    .offset(x: -9, y: -9)
                                Spacer()
                                Text("кв. \(task.client.address.apartmentNumber ?? defaultNumber)")
                                    .foregroundColor(.custom(.taskTextGray))
                                Spacer()
                                Text("под.\(task.client.address.entranceNumber ?? defaultNumber)")
                                    .foregroundColor(.custom(.taskTextGray))
                                Spacer()
                                Text("эт.\(task.client.address.floorNumber ?? 0)")
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
                        
                        Text(task.taskDescription)
                            .font(.custom(SFPro.regular.rawValue, size: 19))
                            .bold()
                            .frame(maxWidth: 350, alignment: .center)
                            .frame(height: 35)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .padding(.top, -22)
                            .padding(.bottom, 5)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack {
                        HStack {
                            Text(task.scheduledAt.formattedAsTime())
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 5)
                            
                            Spacer()
                            HStack {
                                ZStack {
                                    Image("repeatClientCloud")
                                    Text("Клиент\nрепит")
                                        .font(.custom(SFPro.regular.rawValue, size: 12))
                                        .multilineTextAlignment(.center)
                                        .offset(x: -4)
                                }
                                .frame(width: 20)
                                .offset(x: -5, y: 3)
                                .opacity(showRepeatClientBubbleRemote ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: showRepeatClientBubbleRemote)
                                Button(action: {
                                    showRepeatClientBubbleRemote.toggle()
                                }) {
                                    Image("repeatBadge")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(6)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .contentShape(Rectangle())
                                Text(task.client.firstName)
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            }
                            .offset(x: 6)
                            .padding(.trailing, 35)
                           
                            Spacer()
                            ZStack {
                                Image("phoneNumberCloud")
                                Text("\(task.client.phoneNumber)")
                                    .font(.custom(SFPro.regular.rawValue, size: 12))
                                    .offset(x: -3)
                                    .onTapGesture {
                                           if let url = URL(string: "tel://\(task.client.phoneNumber)"),
                                              UIApplication.shared.canOpenURL(url) {
                                               UIApplication.shared.open(url)
                                           }
                                       }
                            }
                            .padding(.leading, -70)
                            .offset(x: 10, y: 3)
                            .opacity(showPhoneNumberCloudRemote ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudRemote)
                            Button(action: {
                                showPhoneNumberCloudRemote.toggle()
                            }) {
                                Image("call")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(6)
                            }
                            .contentShape(Rectangle())
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .frame(maxHeight: 35)
                        
                        .padding(.trailing, 5)
     
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
                            
                        
                        Text(task.taskDescription)
                            .font(.custom(SFPro.bold.rawValue, size: 30))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(maxHeight: 47)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.top, -5)
                    .frame(maxHeight: .infinity)
                }
                    
            }
            .frame(maxHeight: .infinity)

            VStack{
                Rectangle()
                    .frame( height: 0.5)
                    .frame(maxWidth: .infinity)
                    
                
                HStack{
                    Text("Договорились:  \(task.contractAmount)")
                        .font(.custom(SFPro.bold.rawValue, size: 17))
                    
                    Spacer()
                    
                    Text("Итого:")
                        .font(.custom(SFPro.bold.rawValue, size: 19))
                    Image("creditCard")
                }
                .padding(.leading, 32)
                .padding(.trailing, 8)
                .frame(maxHeight: 12)
                
                HStack{
                    Text("Издержки:")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    Text("\(task.cost)")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .foregroundColor(Color.custom(.costPaymentRed))
                    
                    Text("Доплачено:")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    Text("\(task.extraPayment)")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .foregroundColor(Color.custom(.extraPaymentGreen))
                    
                    Spacer()
                    
                    Text("\(task.totalAmount)")
                        .font(.custom(SFPro.bold.rawValue, size: 16))
                    Image("cash")
                }
                .frame(maxHeight: 12)
                .padding(.leading, 11)
                .padding(.trailing, 8)
                .padding(.top, 0)
            }
            .frame(maxHeight: 55)
           
        }
        .background(Color.custom(.taskCellGray))
        .cornerRadius(12)
        
    }
}

#Preview {
    TaskListView()
}

    

