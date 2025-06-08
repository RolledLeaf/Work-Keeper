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
            HStack {
                Color.custom(statusColor)
                    .frame(width: 6, height: 114)
                    .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                    .offset(x: 5, y: 8 )
                VStack {
                    HStack {
                        Text(task.scheduledAt.formattedAsTime())
                            .font(.custom(SFPro.regular.rawValue, size: 16))
                            .offset(x: 9)
                        
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
                    
                    
                    
                    HStack {
                        Text(task.client.address.street)
                            .font(.custom(SFPro.regular.rawValue, size: 15))
                        Text(task.client.address.houseNumber)
                            .font(.custom(SFPro.regular.rawValue, size: 15))
                    }
                    
                    
                    
                    HStack {
                        
                        Image("location")
                            .padding(.leading, -25)
                            .offset(x: -50)
                        Text("кв.")
                        Text(task.client.address.apartmentNumber ?? defaultNumber)
                        Text("под.")
                        Text(task.client.address.entranceNumber ?? defaultNumber)
                        Text("эт.")
                        Text("\(String(describing: task.client.address.floorNumber ?? 1))")
                    }
                    
                    
                    Rectangle()
                        .frame( height: 0.5)
                        .foregroundColor(Color.black)
    
                    Spacer()
                }
            }
            

            
            Text(task.taskDescription)
                .font(.custom(SFPro.regular.rawValue, size: 14))
                .bold()
            Rectangle()
                .frame( height: 0.5)
                .foregroundColor(Color.black)
            
            HStack{
                Text("Договорились:")
                Text("\(task.contractAmount)")
                
                Spacer()
                
                Text("Итого")
                    .font(.custom(SFPro.bold.rawValue, size: 16))
            }
            HStack{
                Text("Издержки:")
                Text("\(task.cost)")
          
                Text("Доплачено:")
                Text("\(task.extraPayment)")
                
                Spacer()
                
                Text("\(task.totalAmount)")
                    .font(.custom(SFPro.bold.rawValue, size: 16))
            }
         Spacer()
            
        }
        .frame(height: 200)
        .background(Color.custom(.taskCellGray))
        .cornerRadius(12)
        
      
        }
    }

#Preview {
    TaskListView()
}
