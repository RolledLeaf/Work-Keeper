import SwiftUI
import UIKit

struct TaskView: View {
 
    @ObservedObject var viewModel = TaskListViewModel()
  
    let task: TaskEntity
  
    @State private var didCopyTaskDescription = false
    @State private var didCopyTaskComment = false
    @State private var didCopyPhoneNumber = false
    @State private var didCopyAddress = false
    
    var body: some View {
        
        let taskStatusColor: CustomColor = {
            switch task.status {
            case .completed: return .taskCompleteGreen
            case .scheduled: return .taskViewYellow
            case .canceled:  return .taskCanceledOrange
            }
        }()
        
        let taskStatusString: String = {
            switch task.status {
            case .completed: return "Завершено"
            case .scheduled: return "Запланировано"
            case .canceled:  return "Отменено"
            }
        }()
        
        return   ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            VStack {
                
                Text("Просмотр задания")
                    .font(.custom(SFPro.regular.rawValue, size: 27))
                    .frame(height: 20)
                HStack {
                    
                    VStack {
                        Text(task.client?.firstName ?? "")
                            .font(.custom(SFPro.bold.rawValue, size: 26))
                        Spacer()
                            .frame(height: 6)
                        
                        
                        Button(action: {
                            let text = (task.client?.phone ?? "")
                          
                            UIPasteboard.general.string = text
                            // Show a quick HUD
                            withAnimation { didCopyPhoneNumber = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation { didCopyPhoneNumber = false
                                }
                            }
                        }) {
                            Text(task.client?.phone ?? "")
                                .font(.custom(SFPro.regular.rawValue, size: 19))
                                .foregroundColor(.custom(.taskTextGray))
                        }
                        
                        
                    }
                    
                    Spacer()
                    
                    
                    ZStack {
                        Color.custom(taskStatusColor)
                        Text(taskStatusString)
                            .frame(width: 133, height: 33)
                        
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    .frame(width: 133, height: 33)
                    .cornerRadius(10)
                    
                    
                }
                .padding(.top, 10)
                .padding(.leading, 32)
                .padding(.trailing, 20)
                
                Spacer()
                    .frame(height: 28)
           
                ZStack {
                    Color.custom(.inactiveFiledGray)
                      
                    VStack {
                        HStack {
                            
                            if task.isRemote {
                                Image("remote")
                                    .offset(x: 20)
                                    .offset(y: 5)
                            } else {
                                Image("mapPinBlack")
                                    .offset(x: 20)
                                    .offset(y: 5)
                            }
                            
                            Spacer()
                            
                            if task.isRemote {
                                Text("Удалёнка")
                                    .font(.custom(SFPro.regular.rawValue, size: 24))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(maxWidth: 306)
                                    .offset(x: -7, y: 7)
                                    
                            } else {
                                
                                Button(action: {
                                    let text = ("\(task.client?.primaryAddress?.street?.name ?? "Адрес не указан") \(task.client?.primaryAddress?.house ?? "")")
                                    UIPasteboard.general.string = text
                                    withAnimation { didCopyAddress = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 ) {
                                        withAnimation { didCopyAddress = false
                                        }
                                    }
                                    
                                }) {
                                    Text("\(task.client?.primaryAddress?.street?.name ?? "Адрес не указан") \(task.client?.primaryAddress?.house ?? "")")
                                        .font(.custom(SFPro.regular.rawValue, size: 24))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .frame(width: 270)
                                        .offset(y: 8)
                                }
                            }
                            
                            Spacer()
                                
                            
                        }
                        Spacer()
                        
                        HStack{
                            Spacer()
                            Rectangle()
                                .frame(width: 345, height: 0.5)
                                .padding(.top, 5)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image("calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            
                            
                            Text(task.scheduledAt?.formattedAsDate() ?? "")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            
                            Image(systemName: "clock")
                            
                            Text(task.scheduledAt?.formattedAsTime() ?? "")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
         
                        }
                        .padding(.leading, 21)
                        .padding(.trailing, 21)
                        
                        Spacer()
                    }
                 
                }
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                )
                .frame(height: 105)
                .padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 15)
                
                HStack {
                    Text("Задание")
                        .font(.custom(SFPro.regular.rawValue, size: 19))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Button(action: {
                        let text = (task.taskDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isBlank else { return }
                        UIPasteboard.general.string = text
                        // Show a quick HUD
                        withAnimation { didCopyTaskDescription = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation { didCopyTaskDescription = false }
                        }
                    }) {
                        Image(systemName: "list.clipboard")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 18, height: 25)
                    }
                    
                }
                .padding(.leading, 30)
                .padding(.trailing, 45)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        
                        Text(task.taskDescription ?? "")
                            .font(.custom(SFPro.regular.rawValue, size: 20))
                            .multilineTextAlignment(.center)
                            .frame(height: 82, alignment: .center)
                            .padding(.horizontal, 5)
                    }
                }
                .frame(height: 82)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                
                HStack {
                    Text("Комментарий")
                        .font(.custom(SFPro.regular.rawValue, size: 19))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Button(action: {
                        let text = (task.comment ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !text.isBlank else { return }
                        UIPasteboard.general.string = text
                        withAnimation { didCopyTaskComment = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation { didCopyTaskComment = false
                            }
                        }
                    }) {
                        Image(systemName: "list.clipboard")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 18, height: 25)
                    }
                   
                    
                }
                .padding(.leading, 30)
                .padding(.trailing, 45)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        
                        Text(task.comment ?? "")
                            .font(.custom(SFPro.regular.rawValue, size: 20))
                            .multilineTextAlignment(.center)

                            .frame(height: 96, alignment: .center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(height: 96)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                
                Spacer()
                    .frame(height: 25)
                
                HStack {
                    Text("Оплата")
                        .font(.custom(SFPro.regular.rawValue, size: 19))
                        .foregroundColor(.custom(.taskTextGray))
                    
                    Spacer()
                }
                .padding(.leading, 30)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        HStack {
                            Text("Договорились")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("\(task.contractAmount.formattedCurrency())")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                        .padding(.top, 15)
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Издержки")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("\(task.cost.formattedCurrency())")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                       
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Доплата")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("\(task.extraPayment.formattedCurrency())")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                       
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Итого")
                                .font(.custom(SFPro.bold.rawValue, size: 24))
                            Spacer()
                            Text("\(task.totalAmount.formattedCurrency())")
                                .font(.custom(SFPro.bold.rawValue, size: 24))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                        Spacer()
                    }
    
                }
                .cornerRadius(8)
                .frame(height: 190)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                Spacer()
            }
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(false)
        }
        .overlay(alignment: .center) {
            if didCopyTaskDescription {
                
                Text("Текст задания скопирован")
                    .font(.custom(SFPro.regular.rawValue, size: 18))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            }
        }
        .overlay(alignment: .center) {
            if didCopyTaskComment {
                Text("Комментарий скопирован")
                    .font(.custom(SFPro.regular.rawValue, size: 18))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            
            }
        }
        
        .overlay(alignment: .center) {
            if didCopyPhoneNumber {
                Text("Номер клиента скопирован")
                    .font(.custom(SFPro.regular.rawValue, size: 18))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 20)
            
            }
        }
            
        .overlay(alignment: .center) {
            if didCopyAddress {
                Text("Адрес клиента скопирован")
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



