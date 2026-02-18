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
    @Binding var selectedClient: Client?
    
    
    var clientTasksCount: Int {
        guard let tasks = task.client?.tasks as? Set<TaskEntity> else { return 0 }
        let actualTasks = tasks.filter { $0.deletedAt == nil }
        return actualTasks.count
    }
    
    
    let task: TaskEntity
    
    private var taskAddress: Address? {
        if let address = task.address {
            return address          // адрес, привязанный к задаче
        } else {
            return task.client?.primaryAddress // fallback для старых заданий
        }
    }
    
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
        
        return ZStack(alignment: .topLeading) {
            VStack {
                
                
                HStack {
                    HStack {
                            Button(action: {
                                if let client = task.client {
                                    selectedClient = client
                                }
                            }) {
                                Text(
                                    highlighted(
                                        task.client?.firstName?.uppercased() ?? "",
                                        query: viewModel.searchText,
                                        highlightColor: .highlightBlue
                                    )
                                )
                                .font(.custom(Montserrat.bold.rawValue, size: 23))
                                .foregroundStyle(.mainBlack)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        
                       
                        
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
                            
                            Text(
                                highlighted(
                                    taskAddress?.street?.name ?? "",
                                    query: viewModel.searchText,
                                    highlightColor: .highlightBlue
                                )
                            )
                            .font(.custom(Montserrat.medium.rawValue, size: 12))
                            .foregroundStyle(.mainBlack)

                            Text(taskAddress?.house ?? "")
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
//                                        .offset(y: -6)
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
                            Image("clockBlack")
                            
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
                            .frame(maxWidth: 250, alignment: .leading)
                            .foregroundStyle(.mainBlack)
                        
                        Spacer()
                    }
                    .frame(height: 20)
                    
                    Spacer()
                }
                .frame(height: 60)
                
                HStack {
                    Image("separateLine2")
                    Spacer()
                }
                .frame(height: 1)
                
                HStack {
                    Text("\(task.totalAmount.formattedCurrency())")
                        .font(.custom(Montserrat.bold.rawValue, size: 25))
                                  .foregroundStyle(task.totalAmount >= 0 ? .mainBlack : .red)
                    +
                    Text(" ₽")
                        .font(.custom(Montserrat.regular.rawValue, size: 25))
                        .foregroundStyle(.mainBlack)
                    Spacer()
                    Image(paymentIconResource ?? ImageResource.init(name: "cash", bundle: .main))
                        .padding(.trailing, 20)
                        .frame(width: 25, height: 25)
                        .opacity(task.status == .completed ? 1 : 0)
                }
                .frame(height: 25)
               
            }
           
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
            
        }
        .background(
            Image(statusImage)
                .resizable(
                    resizingMode: .stretch
                    
                )
                .frame(maxWidth: .infinity)
                       .frame(height: 177)
                       
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
