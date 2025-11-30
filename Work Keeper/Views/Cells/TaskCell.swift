
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
                    HStack {
                        Text(highlighted(task.client?.firstName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.bold.rawValue, size: 23))
                            .foregroundStyle(.mainBlack)
                  
                        
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
                
             
   
                VStack(spacing: 2) {
                    if !task.isRemote {
                        
                        HStack {
                            
                            ZStack {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.custom(.mainBlack))
                                    .opacity(0.2)
                                Image("location")
                                
                            }
                            
                            Text(highlighted(task.client?.primaryAddress?.street?.name ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                                .foregroundStyle(.mainBlack)
                            
                            Text("\(task.client?.primaryAddress?.house ?? "")")
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                                .foregroundStyle(.mainBlack)
                            
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                       UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image("call")
                                        .offset(y: -6)
                                }
                                .contentShape(Rectangle())
                                .buttonStyle(BorderlessButtonStyle())
                                Spacer()
                            }
                       
                            
                        }
                        .lineLimit(1, reservesSpace: false)
                        .foregroundColor(.mainBlack)
                        .frame(height: 20)
//                        .padding(.trailing, 10)
                        
                    } else {
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.custom(.mainBlack))
                                    .opacity(0.2)
                                Image("remote")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                            
                            Text("Удалёнка")
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                 
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
                                       UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Image("call")
                                        .offset(y: -6)
                                }
                                .contentShape(Rectangle())
                                .buttonStyle(BorderlessButtonStyle())
                                Spacer()
                            }
                            
                        }
                        .lineLimit(1, reservesSpace: false)
                        .foregroundColor(.mainBlack)
                        .frame(height: 20)
//                        .padding(.trailing, 10)
                        
                    }
                    
                    HStack {
                        
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.custom(.mainBlack))
                                .opacity(0.2)
                            Image("clock")
                            
                        }
                       
                        
                        Text(task.scheduledAt?.formattedAsTime() ?? "\(Date())")
                            .font(.custom(Montserrat.medium.rawValue, size: 12))
                            .foregroundStyle(.mainBlack)
                        
                        Spacer()
                        
                    }
                    .frame(height: 20)
                    
                    
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.custom(.mainBlack))
                                .opacity(0.2)
                            Image("taskDesc")
                            
                        }
                     
                        Text(highlighted(task.taskDescription ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.medium.rawValue, size: 12, ))
                            .frame(maxWidth: 285, alignment: .leading)
                            .foregroundStyle(.mainBlack)
                        
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
                                  .foregroundStyle(.mainBlack)
                    Text("₽")
                        .font(.custom(Montserrat.regular.rawValue, size: 25))
                        .foregroundStyle(.mainBlack)
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
//    VStack {
//        
//        HStack { //Начало первого главного горизонтального стека
//            
//            VStack { // Левый вертикальный стек
//                
//                HStack {
//                    Text(highlighted(task.client?.firstName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                        .font(.custom(Montserrat.bold.rawValue, size: 23))
//                        .foregroundStyle(.mainBlack)
//                    
//                    
//                    Button(action: {
//                        showRepeatClientBubbleLocal = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            withAnimation {
//                                showRepeatClientBubbleLocal = false
//                            }
//                        }
//                    }) {
//                        Image("repeatBadge")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                        
//                    }
//                    .buttonStyle(BorderlessButtonStyle())
//                    .contentShape(Circle())
//                    .opacity(repeatBadgeOpacity)
//                    .onAppear {
//                        repeatBadgeOpacity = clientTasksCount > 1 ? 1 : 0
//                    }
//                    Spacer()
//                } // конец стека имени клиента
//                
//                if !task.isRemote {
//                    
//                    HStack {
//                        
//                        ZStack {
//                            Circle()
//                                .frame(width: 20, height: 20)
//                                .foregroundStyle(Color.custom(.mainBlack))
//                                .opacity(0.2)
//                            Image("location")
//                            
//                        }
//                        
//                        Text(highlighted(task.client?.primaryAddress?.street?.name ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                            .font(.custom(Montserrat.medium.rawValue, size: 12))
//                            .foregroundStyle(.mainBlack)
//                        
//                        Text("\(task.client?.primaryAddress?.house ?? "")")
//                            .font(.custom(Montserrat.medium.rawValue, size: 12))
//                            .foregroundStyle(.mainBlack)
//                        
//                        Spacer()
//                        
//                        
//                        
//                        
//                    }
//                    .lineLimit(1, reservesSpace: false)
//                    .foregroundColor(.mainBlack)
//                    .frame(height: 20)
//                    //                        .padding(.trailing, 10)
//                    
//                } else {
//                    
//                    HStack {
//                        ZStack {
//                            Circle()
//                                .frame(width: 20, height: 20)
//                                .foregroundStyle(Color.custom(.mainBlack))
//                                .opacity(0.2)
//                            Image("remote")
//                                .resizable()
//                                .frame(width: 14, height: 14)
//                        }
//                        
//                        Text("Удалёнка")
//                            .font(.custom(Montserrat.medium.rawValue, size: 12))
//                        
//                        Spacer()
//                        
//                        
//                        
//                    }
//                    .lineLimit(1, reservesSpace: false)
//                    .foregroundColor(.mainBlack)
//                    .frame(height: 20)
//                    //                        .padding(.trailing, 10)
//                } // Конец стека адреса или удалёнки
//                
//                HStack {  //Начало стека времени
//                    
//                    ZStack {
//                        Circle()
//                            .frame(width: 20, height: 20)
//                            .foregroundStyle(Color.custom(.mainBlack))
//                            .opacity(0.2)
//                        Image("clock")
//                        
//                    }
//                    
//                    
//                    Text(task.scheduledAt?.formattedAsTime() ?? "\(Date())")
//                        .font(.custom(Montserrat.medium.rawValue, size: 12))
//                        .foregroundStyle(.mainBlack)
//                    
//                    Spacer()
//                    
//                }
//                .frame(height: 20)
//                //конец стека времени
//                
//                HStack { //Начало стека описания задания
//                    ZStack {
//                        Circle()
//                            .frame(width: 20, height: 20)
//                            .foregroundStyle(Color.custom(.mainBlack))
//                            .opacity(0.2)
//                        Image("taskDesc")
//                        
//                    }
//                    
//                    Text(highlighted(task.taskDescription ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
//                        .font(.custom(Montserrat.medium.rawValue, size: 12, ))
//                        .frame(maxWidth: 285, alignment: .leading)
//                        .foregroundStyle(.mainBlack)
//                    
//                    Spacer()
//                }
//                .frame(height: 20)
//                //Конец стека описания задания
//                
//                
//            } // Конец левого вертикального стека
//            
//            
//            VStack { //Правый вертикальный стек
//                
//                Button(action: {
//                    if let url = URL(string: "tel://\(task.client?.phone ?? "")"),
//                       UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url)
//                    }
//                }) {
//                    Circle()
//                        .frame(width: 44, height: 44)
//                }
////                        .padding(.top, 25)
//                .contentShape(Rectangle())
//                .buttonStyle(BorderlessButtonStyle())
//                
//                Spacer()
//            } // Конец правого вертикального стека
//            
//        } //Конец первого главного горизонтального стека
//        
//     
//
//     
//
//        HStack {
//            Image("separateLine2")
//            Spacer()
//        }
//        .frame(height: 1)
//        
//        HStack {
//            Text("\(task.totalAmount.formattedCurrency())")
//                .font(.custom(Montserrat.bold.rawValue, size: 25))
//                          .foregroundStyle(.mainBlack)
//            Text("₽")
//                .font(.custom(Montserrat.regular.rawValue, size: 25))
//                .foregroundStyle(.mainBlack)
//            Spacer()
//        }
//        .frame(height: 25)
//       
//    }
//   
//    //Конец вертикального стека UI Элементов
//    
//}
//
//.padding(.leading, 20)
//.padding(.trailing, 10)
//.background(
//    Image(statusImage)
//        .resizable()
//                .scaledToFill()
//)
//
//
//
//
//.overlay(alignment: .center) {
//    if showRepeatClientBubbleLocal {
//        Text("Это регулярный клиент")
//            .font(.custom(SFPro.regular.rawValue, size: 18))
//            .padding(.horizontal, 14)
//            .padding(.vertical, 8)
//            .background(.ultraThinMaterial)
//            .clipShape(Capsule())
//            .padding(.top, 20)
//    
//    }
//}
//
//}
//
//}
