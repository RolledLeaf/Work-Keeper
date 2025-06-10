import SwiftUI

let defaultNumber = "1"

struct TaskRow: View {
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
                    .frame(width: 6, height: 114)
                    .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                    .offset(x: 5)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                if task.isRemote == false {
                    VStack {
                        HStack {
                            Text(task.scheduledAt.formattedAsTime())
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 20)
                            
                            Spacer()
                            HStack {
                                Image("repeatBadge")
                                
                                
                                Text(task.client.firstName)
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            }
                            .offset(x: -18)
                            
                            Spacer()
                            
                            Image("call")
                                .offset(x: -8)
                        }
                        
                        
                        Text("\(task.client.address.street) \(task.client.address.houseNumber)")
                            .font(.custom(SFPro.regular.rawValue, size: 25))
                            .foregroundColor(.custom(.taskTextGray))
                        
                            .padding(.leading, 20)
                            .padding(.top, -12)
                            .padding(.bottom, -5)
                            .frame(maxWidth: 300, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                        
                        HStack {
                            if task.client.address.isPrivateHouse == false {
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
                            } else {
                                Image("location")
                                    .offset(y: -20)
                                
                                Spacer()
                                Text("(Частный дом)")
                                    .font(.custom(SFPro.italic.rawValue, size: 20))
                                    .foregroundColor(.custom(.taskTextGray))
                                    .offset(x: -19)
                            }
                        }
                        .padding(.trailing, 90)
                        .padding(.leading, 15)
                        
                        
                        Rectangle()
                            .frame( height: 0.5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .padding(.top, -15)
                        
                        Text(task.taskDescription)
                            .font(.custom(SFPro.regular.rawValue, size: 24))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .padding(.top, -20)
                            .padding(.bottom, 5)
                        
                    }
                    .frame(maxHeight: 150)
                } else {
                    VStack {
                        HStack {
                            Text(task.scheduledAt.formattedAsTime())
                                .font(.custom(SFPro.regular.rawValue, size: 16))
                                .offset(x: 20)
                            
                            Spacer()
                            HStack {
                                Image("repeatBadge")
                                
                                
                                Text(task.client.firstName)
                                    .font(.custom(SFPro.bold.rawValue, size: 25))
                            }
                            .offset(x: -18)
                            
                            Spacer()
                            
                            Image("call")
                                .offset(x: -8)
                        }
                        .padding(.top, -20)
     
                        HStack{
                               Image("remote")
                                   .offset(y: -10)
                               Spacer()
                       
                               Text("Удалёнка")
                                   .font(.custom(SFPro.regular.rawValue, size: 30))
                                   .foregroundColor(.custom(.taskTextGray))
                                   .padding(.top, -19)
                           }
                        
                        .padding(.trailing, 120)
                        .padding(.leading, 15)
                        
                        
                        Rectangle()
                            .frame( height: 0.5)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .padding(.top, -15)
                        
                        Text(task.taskDescription)
                            .font(.custom(SFPro.regular.rawValue, size: 30))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(2, reservesSpace: false)
                            .minimumScaleFactor(0.5)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .padding(.top, -10)
                           
                        
                    }
                    .frame(maxHeight: 150)
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
                .padding(.leading, 49)
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
        .frame(height: 200)
        .background(Color.custom(.taskCellGray))
        .cornerRadius(12)
    }
}

#Preview {
    TaskListView()
}

    
//    
//} else {
//    HStack{
//        Image("remote")
//            .offset(y: -10)
//        Spacer()
//  
//        Text("Удалёнка")
//            .font(.custom(SFPro.regular.rawValue, size: 30))
//            .foregroundColor(.custom(.taskTextGray))
//            .padding(.top, -25)
//    }
//    .frame(height: 50)
//    .padding(.leading, 20)
//    .padding(.trailing, 110)
//    
//    
//}
//    
//HStack {
//    Color.custom(statusColor)
//        .frame(width: 6, height: 114)
//        .cornerRadius(15, corners: [.topLeft, .bottomLeft])
//        .offset(x: 5, y: 5)
//
//    VStack {
//
//        HStack {
//            Text(task.scheduledAt.formattedAsTime())
//                .font(.custom(SFPro.regular.rawValue, size: 16))
//                .offset(x: 9)
//
//            Spacer()
//            HStack {
//                Image("repeatBadge")
//
//
//                Text(task.client.firstName)
//                    .font(.custom(SFPro.bold.rawValue, size: 25))
//            }
//            .offset(x: -18)
//
//            Spacer()
//
//            Image("call")
//                .offset(x: -8)
//        }
//        .offset(y: 16)
//
//                Text("\(task.client.address.street) \(task.client.address.houseNumber)")
//                    .font(.custom(SFPro.regular.rawValue, size: 25))
//                    .foregroundColor(.custom(.taskTextGray))
//
//                    .padding(.leading, 20)
//
//                    .frame(maxWidth: 280)
//                    .frame(height: 36)
//                    .lineLimit(2)
//                    .minimumScaleFactor(0.5)
//
//
//        HStack {
//            Spacer()
//
//
//            if task.client.address.isPrivateHouse == false {
//                Image("location")
//                    .offset(x: 30, y: -17)
//                Spacer()
//                Text("кв. \(task.client.address.apartmentNumber ?? defaultNumber)")
//                    .foregroundColor(.custom(.taskTextGray))
//                Spacer()
//                Text("под.\(task.client.address.entranceNumber ?? defaultNumber)")
//                    .foregroundColor(.custom(.taskTextGray))
//                Spacer()
//                Text("эт.\(task.client.address.floorNumber ?? 0)")
//                    .foregroundColor(.custom(.taskTextGray))
//            } else {
//                Image("location")
//                    .offset(x: -10, y: -17)
//                Spacer()
//                Text("(Частный дом)")
//                    .font(.custom(SFPro.italic.rawValue, size: 20))
//                    .offset(x: -35)
//            }
//
//        }
//
//        .offset(x: -70, y: -25)
//
//
//        Rectangle()
//            .frame( height: 0.5)
//            .foregroundColor(Color.black)
//            .offset(y: -40)
//
//        Text(task.taskDescription)
//            .font(.custom(SFPro.regular.rawValue, size: 24))
//            .bold()
//
//            .frame(maxWidth: 340)
//            .frame(maxHeight: 25, alignment: .center)
//            .lineLimit(2, reservesSpace: true)
//            .minimumScaleFactor(0.5)
//    }
//    .frame(maxHeight: 150, alignment: .bottom)
//
//    .multilineTextAlignment(.center)
//
//}
//
//
//
//
//VStack {
//
//    Rectangle()
//        .frame( height: 0.5)
//        .foregroundColor(Color.black)
//
//
//    HStack{
//        Text("Договорились:  \(task.contractAmount)")
//            .font(.custom(SFPro.bold.rawValue, size: 17))
//            .offset(x: 49)
//        Spacer()
//
//        Text("Итого:")
//            .font(.custom(SFPro.bold.rawValue, size: 19))
//            .offset(x: -10)
//    }
//    .offset(y: 0)
//
//    HStack{
//        Text("Издержки: \(task.cost)")
//            .font(.custom(SFPro.regular.rawValue, size: 15))
//
//        Text("Доплачено: \(task.extraPayment)")
//            .font(.custom(SFPro.regular.rawValue, size: 15))
//        Spacer()
//
//        Text("\(task.totalAmount)")
//            .font(.custom(SFPro.bold.rawValue, size: 16))
//            .offset(x: -9)
//    }
//    .padding(.leading, 17)
//}
//.offset(y: -10)
