import SwiftUI

let defaultNumber = "1"

struct TaskRow: View {
    let task: Task
    
    var body: some View {
        ZStack {
            Color(CustomColor.taskCellGray.rawValue)
            VStack {
                HStack {
                    Text(task.scheduledAt.formattedAsTime())
                        .font(.custom("SFPro", size: 16))
                        .padding(.leading, 15)
                         
                    Spacer()
                         
                    Image("repeatBadge")
                        .padding(.trailing, 5)
                     
                    Text(task.client.firstName)
                        .font(.custom("SFPro", size: 20))
                        .fontWeight(.bold)
                    
                    Spacer()
                    Image("call")
                        .padding(.trailing, 9)
                        .padding(.top, 6)
                }
                    
                HStack {
                    Text(task.client.address.street)
                        .font(.custom("SFPro", size: 15))
                    Text(task.client.address.houseNumber)
                        .font(.custom("SFPro", size: 15))
                }
                  
                    HStack {
                        Image("location")
                        Text("кв.")
                        Text(task.client.address.apartmentNumber ?? defaultNumber)
                        Text("под.")
                        Text(task.client.address.entranceNumber ?? defaultNumber)
                        Text("эт.")
                        Text("\(String(describing: task.client.address.floorNumber ?? 1))")
                    }
                    
                    Text(task.taskDescription)
                        .font(.caption)
                
                Spacer()
                }
                Spacer()
               
            }
            .frame(height: 167)
        }
    }

