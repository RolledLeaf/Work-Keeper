import SwiftUI

struct TaskView: View {
 
    @ObservedObject var viewModel = TaskListViewModel()
  
    let task: Task
  
    
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
                        
                        Text(task.client?.phone ?? "")
                            .font(.custom(SFPro.regular.rawValue, size: 16))
                            .foregroundColor(.custom(.taskTextGray))
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
                                Text("\(task.client?.primaryAddress?.street?.name ?? "Адрес не указан") \(task.client?.primaryAddress?.house ?? "")")
                                    .font(.custom(SFPro.regular.rawValue, size: 24))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                    .frame(width: 270)
                                    .offset(y: 8)
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
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Image("pen")
                    
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
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                
                HStack {
                    Text("Комментарий")
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Image("pen")
                    
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
                        .font(.custom(SFPro.regular.rawValue, size: 16))
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
    }
}


