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
                    .frame(width: 6, height: 130)
                    .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                    .offset(x: 5)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
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
                                    showRepeatClientBubbleLocal.toggle()
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
                            }
                          
                            .padding(.leading, -70)
                            .offset(x: 11)
                            .opacity(showPhoneNumberCloudLocal ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudLocal)
                            Button(action: {
                                showPhoneNumberCloudLocal.toggle()
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
                        
                        
                        Text("\(task.client.address.street) \(task.client.address.houseNumber)")
                            .font(.custom(SFPro.regular.rawValue, size: 32))
                            .foregroundColor(.custom(.taskTextGray))
                        
                            .padding(.leading, 20)
                            .padding(.top, -12)
                            .padding(.bottom, -5)
                            .frame(width: 300, alignment: .center)
                            .frame(height: 25)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                        if task.client.address.isPrivateHouse == false {
                            HStack {
                                
                                Image("location")
                                    .offset(x: -9, y: -20)
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
                                    .offset(y: -20)
                                
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
                    .frame(maxHeight: 150)
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
                                .offset(x: 9, y: 3)
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
                        .padding(.top, -20)
                        .padding(.trailing, 5)
     
                        HStack{
                               Image("remote")
                                   
                               Spacer()
                       
                               Text("Удалёнка")
                                   .font(.custom(SFPro.regular.rawValue, size: 30))
                                   .foregroundColor(.custom(.taskTextGray))
                                   .padding(.top, -15)
                                   .offset(x: 10, y: 2)
                           }
                        .padding(.top, -20)
                        .padding(.trailing, 120)
                        .padding(.leading, 10)
                        
                        
                        Rectangle()
                            .frame( height: 0.5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .padding(.top, -5)
                        
                        Text(task.taskDescription)
                            .font(.custom(SFPro.regular.rawValue, size: 30))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .offset(y: -7)
                           
                        
                    }
                    .frame(height: 150)
                }
            }
            
            
            Rectangle()
                .frame( height: 0.5)
                .frame(maxWidth: .infinity)
                .padding(.top, -9)
            
            VStack{
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
                
                HStack{
                    Text("Издержки: \(task.cost)")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    
                    Text("Доплачено: \(task.extraPayment)")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                    Spacer()
                    
                    Text("\(task.totalAmount)")
                        .font(.custom(SFPro.bold.rawValue, size: 16))
                    Image("cash")
                }
                .padding(.leading, 11)
                .padding(.trailing, 8)
                .padding(.top, -10)
            }
            .padding(.top, -12)
        }
        .background(Color.custom(.taskCellGray))
        .cornerRadius(12)
        
    }
}

#Preview {
    TaskListView()
}

    

