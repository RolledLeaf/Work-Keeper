
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
    @ObservedObject var viewModel: TaskListViewModel
    
    
    var clientTasksCount: Int {
        guard let tasks = task.client?.tasks as? Set<TaskEntity> else { return 0 }
        return tasks.count
    }
    
    
    let task: TaskEntity
    
    private var paymentIconResource: ImageResource? {
        guard let paymentTypeRaw = task.paymentType,
              let paymentType = PaymentType(rawValue: paymentTypeRaw) else {
            return nil
        }
        
        switch paymentType {
        case .cash:
            return ImageResource(name: "cash", bundle: .main)
        case .transfer:
            return ImageResource(name: "creditCard", bundle: .main)
        case .none:
            return nil
        }
    }
    
    
    
    var body: some View {
        
        let statusImage: ImageResource
        
        switch task.status {
        case .scheduled:
            statusImage = ImageResource(name: "taskCellScheduled", bundle: .main)
        case .completed:
            statusImage = ImageResource(name: "taskCellCompleted", bundle: .main)
        case .canceled:
            statusImage = ImageResource(name: "taskCellCanceled", bundle: .main)
            
        }
        
        return VStack {
            VStack {
                
                HStack {
                    HStack(spacing: 4) {
                        Text(highlighted(task.client?.firstName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.bold.rawValue, size: 23))
                            .foregroundStyle(.black)
                            
                            
                        
                        
                        
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
                                
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .contentShape(Circle())
                        .opacity(repeatBadgeOpacity)
                        .onAppear {
                            repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
                        }
                    }
                   
                    
                    Spacer()
                }
                .padding(.top, 11)
                .frame(height: 23)
   
                VStack(spacing: 2) {
                    if !task.isRemote {
                        
                        HStack {
                            
                            ZStack {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.custom(.mainBackground))
                                    .opacity(0.2)
                                Image("location")
                                
                            }
                            
                            Text(highlighted(task.client?.primaryAddress?.street?.name ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                            
                            
                            Text("\(task.client?.primaryAddress?.house ?? "")")
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                            
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image("call")
                                
                            }
                            .contentShape(Rectangle())
                            .buttonStyle(BorderlessButtonStyle())
                            
                        }
                        .lineLimit(1, reservesSpace: false)
                        .foregroundColor(.black)
                        .frame(height: 20)
                        .padding(.trailing, 10)
                        
                    } else {
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.custom(.mainBackground))
                                    .opacity(0.2)
                                Image("remote")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                            
                            Text("Удалёнка")
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                 
                            Spacer()
                            
                            Button(action: {
                                if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Image("call")
                                
                            }
                            .contentShape(Rectangle())
                            .buttonStyle(BorderlessButtonStyle())
                            
                        }
                        .lineLimit(1, reservesSpace: false)
                        .foregroundColor(.black)
                        .frame(height: 20)
                        .padding(.trailing, 10)
                        
                    }
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.custom(.mainBackground))
                                .opacity(0.2)
                            Image("clock")
                            
                        }
                       
                        
                        Text(task.scheduledAt?.formattedAsTime() ?? "\(Date())")
                            .font(.custom(Montserrat.medium.rawValue, size: 12))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                    }
                    .frame(height: 20)
                    
                    
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.custom(.mainBackground))
                                .opacity(0.2)
                            Image("taskDesc")
                            
                        }
                     
                        Text(highlighted(task.taskDescription ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.medium.rawValue, size: 12, ))
                            .frame(maxWidth: 285, alignment: .leading)
                            .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    .frame(height: 20)
                    
                }
                
                HStack {
                    Image("separateLine2")
                    Spacer()
                }
                .frame(height: 1)
                
                HStack {
                    Text("\(task.totalAmount.formattedCurrency())")
                        .font(.custom(Montserrat.bold.rawValue, size: 25))
                                  .foregroundStyle(.black)
                    Spacer()
                }
                .frame(height: 25)
               
            }
           
            //Конец вертикального стека UI Элементов
            
        }
      
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .background(
            Image(statusImage)
                .resizable()
                        .scaledToFill()
        )
        
        .frame(height: 167)
        
        
        .overlay(alignment: .center) {
            if showRepeatClientBubbleLocal {
                Text("Это регулярный клиент")
                    .font(.custom(SFPro.regular.rawValue, size: 18))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            
            }
        }
        
    }
        
}





//return VStack {
//    HStack{
//
//        if task.isRemote == false {
//            VStack {
//                HStack {
//                    Text(task.scheduledAt?.formattedAsTime() ?? "\(Date())")
//                        .font(.custom(Montserrat.regular.rawValue, size: 16))
//                        .offset(x: 5)
//
//                    Spacer ()
//
//
//                    VStack {
//                        Image("cornerCurve")
//                        Image("corner")
//                    }
//
//                }
//                .padding(.trailing, 4)
//
//                HStack {
//
//
//
//
//                    Text(highlighted(task.client?.firstName ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                        .font(.custom(Montserrat.bold.rawValue, size: 23))
//
//                        ZStack {
//                            Image("repeatClientCloud")
//
//                            Text("Клиент\nрепит")
//                                .font(.custom(SFPro.regular.rawValue, size: 12))
//                                .multilineTextAlignment(.center)
//                                .offset(x: -4)
//
//                        }
//                        .frame(width: 20)
//                        .offset(x: -8, y: 2)
//                        .opacity(showRepeatClientBubbleLocal ? 1 : 0)
//                        .animation(.easeInOut(duration: 0.3), value: showRepeatClientBubbleLocal)
//
//
//
//                        Button(action: {
//                            showRepeatClientBubbleLocal = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                withAnimation {
//                                    showRepeatClientBubbleLocal = false
//                                }
//                            }
//                        }) {
//                            Image("repeatBadge")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                                .padding(6)
//                        }
//                        .buttonStyle(BorderlessButtonStyle())
//                        .contentShape(Circle())
//                        .opacity(repeatBadgeOpacity)
//                        .onAppear {
//                            repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
//                        }
//
//
//                    Spacer()
//
//                    ZStack {
//                        Image("phoneNumberCloud")
//
//
//                        Text("\(task.client?.phone ?? "")")
//                            .font(.custom(SFPro.regular.rawValue, size: 13))
//                            .offset(x: -3)
//                            .onTapGesture {
//                                if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
//                                      UIApplication.shared.canOpenURL(url) {
//                                       UIApplication.shared.open(url)
//                                   }
//                               }
//                    }
//
//                    .offset(x: 11)
//                    .opacity(showPhoneNumberCloudLocal ? 1 : 0)
//                    .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudLocal)
//

//
//
//                }
//
//                .frame(maxHeight: 35)
//
//                HStack {
//                    Text(highlighted(task.client?.primaryAddress?.street?.name ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2, reservesSpace: false)
//                        .minimumScaleFactor(1)
//
//                    Text("\(task.client?.primaryAddress?.house ?? "")")
//
//
//                }
//                .font(.custom(SFPro.regular.rawValue, size: 22))
//                    .foregroundColor(.custom(.taskTextGray))
//                    .frame(height: 25)
//                    .frame(width: 320, alignment: .center)
//                    .offset(y: -3)
//
//
//                if task.client?.primaryAddress?.isPrivateHouse == false {
//                    HStack {
//
//
//                        Text("\(task.client?.primaryAddress?.roomType ?? "кв.") \(task.client?.primaryAddress?.apartment ?? defaultNumber)")
//
//                            .foregroundColor(.custom(.taskTextGray))
//                        Spacer()
//                        Text("\(task.client?.primaryAddress?.entranceType ?? "под.") \(task.client?.primaryAddress?.entrance ?? defaultNumber)")
//
//                            .foregroundColor(.custom(.taskTextGray))
//                        Spacer()
//                        Text("эт. \(task.client?.primaryAddress?.floor ?? "")")
//
//                            .foregroundColor(.custom(.taskTextGray))
//                    }
//                    .font(.custom(SFPro.regular.rawValue, size: 18))
//                    .offset(y: -4)
//                    .padding(.horizontal, 40)
//                    } else {
//                        HStack {
//
//                        Text("(Только дом)")
//                            .font(.custom(SFPro.italic.rawValue, size: 20))
//                            .foregroundColor(.custom(.taskTextGray))
//
//                    }
//                        .offset(y: -5)
//                }
//
//
//
//                Rectangle()
//                    .frame( height: 0.5)
//                    .frame(maxWidth: .infinity)
//                    .foregroundColor(Color.black)
//                    .padding(.top, -15)
//
//                Text(highlighted(task.taskDescription ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                    .font(.custom(SFPro.regular.rawValue, size: 22))
//                    .bold()
//                    .frame(maxWidth: 355, alignment: .center)
//                    .frame(height: 40)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2, reservesSpace: false)
//                    .minimumScaleFactor(0.65)
//                    .padding(.leading, 5)
//                    .padding(.trailing, 5)
//                    .padding(.top, -15)
//                    .padding(.bottom, 5)
//            }
//            .frame(maxHeight: .infinity)
//        } else {
//            VStack {
//                HStack {
//                    Text(task.scheduledAt?.formattedAsTime() ?? "\(Date())")
//                        .font(.custom(SFPro.regular.rawValue, size: 16))
//                        .offset(x: 5)
//
//                    HStack {
//                        ZStack {
//                            Image("repeatClientCloud")
//
//                            Text("Клиент\nрепит")
//                                .font(.custom(SFPro.regular.rawValue, size: 12))
//                                .multilineTextAlignment(.center)
//                                .offset(x: -4)
//
//                        }
//                        .frame(width: 20)
//                        .offset(x: -8, y: 2)
//                        .opacity(showRepeatClientBubbleLocal ? 1 : 0)
//                        .animation(.easeInOut(duration: 0.3), value: showRepeatClientBubbleLocal)
//
//                        Button(action: {
//                            showRepeatClientBubbleLocal = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                withAnimation {
//                                    showRepeatClientBubbleLocal = false
//                                }
//                            }
//                        }) {
//                            Image("repeatBadge")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                                .padding(6)
//                        }
//                        .buttonStyle(BorderlessButtonStyle())
//                        .contentShape(Circle())
//                        .opacity(repeatBadgeOpacity)
//                        .onAppear {
//                            repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
//                        }
//
//                        Text(highlighted(task.client?.firstName ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                            .font(.custom(SFPro.bold.rawValue, size: 25))
//
//                    }
//                    .frame(maxWidth: 200, alignment: .center)
//
//                    Spacer()
//
//                    ZStack {
//                        Image("phoneNumberCloud")
//                        Text("\(task.client?.phone ?? "")")
//                            .font(.custom(SFPro.regular.rawValue, size: 13))
//                            .offset(x: -3)
//                            .onTapGesture {
//                                if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
//                                      UIApplication.shared.canOpenURL(url) {
//                                       UIApplication.shared.open(url)
//                                   }
//                               }
//                    }
//
//                    .padding(.leading, -70)
//                    .offset(x: 11)
//                    .opacity(showPhoneNumberCloudLocal ? 1 : 0)
//                    .animation(.easeInOut(duration: 0.3), value: showPhoneNumberCloudLocal)
//                    Button(action: {
//                        showPhoneNumberCloudLocal = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            withAnimation {
//                                showPhoneNumberCloudLocal = false
//                            }
//                        }
//                    }) {
//                        Image("call")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                            .padding(6)
//                    }
//                    .contentShape(Rectangle())
//                    .buttonStyle(BorderlessButtonStyle())
//                }
//                .padding(.trailing, 5)
//                .frame(maxHeight: 35)
//
//                HStack{
//                       Image("remote")
//                        .offset(y: -2)
//                       Spacer()
//
//                       Text("Удалёнка")
//                           .font(.custom(SFPro.regular.rawValue, size: 27))
//                           .foregroundColor(.custom(.taskTextGray))
//                                                      }
//                .frame(height: 23)
//                .padding(.trailing, 125)
//                .padding(.leading, 8)
//
//
//                Rectangle()
//                    .frame( height: 0.5)
//                    .frame(maxWidth: .infinity)
//                    .foregroundColor(Color.black)
//
//
//                Text(highlighted(task.taskDescription ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                    .font(.custom(SFPro.bold.rawValue, size: 30))
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .frame(maxHeight: 40)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2, reservesSpace: false)
//                    .minimumScaleFactor(0.5)
//
//            }
//            .frame(maxHeight: .infinity)
//        }
//
//    }
//    .frame(maxHeight: .infinity)
//
//    VStack{
//        Rectangle()
//            .frame( height: 0.5)
//            .frame(maxWidth: .infinity)
//
//
//        HStack{
//            Text("Договорились:  \(task.contractAmount.formattedCurrency())")
//                .font(.custom(SFPro.bold.rawValue, size: 17))
//
//            Spacer()
//
//            Text("Итого:")
//                .font(.custom(SFPro.bold.rawValue, size: 19))
//
//        }
//        .padding(.leading, 32)
//        .padding(.trailing, 2)
//        .frame(maxHeight: 12)
//
//        HStack{
//            Text("Издержки:")
//                .font(.custom(SFPro.regular.rawValue, size: 15))
//            Text("\(task.cost.formattedCurrency())")
//                .font(.custom(SFPro.regular.rawValue, size: 15))
//                .foregroundColor(Color.custom(.costPaymentRed))
//
//            Text("Доплачено:")
//                .font(.custom(SFPro.regular.rawValue, size: 15))
//            Text("\(task.extraPayment.formattedCurrency())")
//                .font(.custom(SFPro.regular.rawValue, size: 15))
//                .foregroundColor(Color.custom(.extraPaymentGreen))
//
//            Spacer()
//
//            Text("\(task.totalAmount.formattedCurrency())")
//                .font(.custom(SFPro.bold.rawValue, size: 16))
//                .foregroundStyle(task.totalAmount >= 0 ? Color.custom(.pitchBlack) : Color.custom(.costPaymentRed))
//
//
//            if let icon = paymentIconResource {
//                Image(icon)
//                    .resizable()
//                    .frame(
//                        width: 20,
//                        height: task.paymentType == PaymentType.transfer.rawValue ? 15 : 20
//                    )
//            }
//        }
//        .frame(maxHeight: 12)
//        .padding(.leading, 11)
//        .padding(.trailing, 4)
//
//    }
//    .frame(maxHeight: 55)
//    .padding(.top, -10)
//}
//.background(
//   RoundedRectangle(cornerRadius: 38)
//            .fill(Color.custom(statusColor))
//)
//.frame(height: 167)
//.onAppear {
//    print("\(task.taskDescription ?? "Без названия") Payment type is \(task.paymentType ?? "нет метода оплаты")")
//}
//}
//}
//
//
//
//
//
//
