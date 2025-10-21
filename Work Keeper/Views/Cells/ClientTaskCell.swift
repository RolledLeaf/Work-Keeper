import SwiftUI

struct ClientTaskCell: View {
    
    let task: TaskEntity
    
    var body: some View {
        let statusGradient: LinearGradient
        switch task.status {
        case .scheduled:
            statusGradient = LinearGradient(
                colors: [Color.custom(.yellowStartPoint), Color.custom(.yellowEndPoint)],
                startPoint: .leading, endPoint: .trailing
            )
        case .completed:
            statusGradient = LinearGradient(
                colors: [Color.custom(.greenStartPoint), Color.custom(.greenEndPoint)],
                startPoint: .leading, endPoint: .trailing
            )
        case .canceled:
            statusGradient = LinearGradient(
                colors: [Color.custom(.orangeStartPoint), Color.custom(.orangeEndPoint)],
                startPoint: .leading, endPoint: .trailing
            )
        }
        
        return  ZStack {
        VStack {
            HStack {
                
                VStack {
                    Text("\(task.scheduledAt?.formattedAsShortDate() ?? Date().formattedAsDate())")
                        .font(.custom(SFPro.regular.rawValue, size: 20))
                    
                    Rectangle()
                        .frame(width: 99, height: 0.5)
                    
                    Text("\(task.totalAmount.formattedCurrency())")
                        .font(.custom(SFPro.regular.rawValue, size: 20))
                }
                .padding(.vertical, 6)
                Spacer()
                
                Text(task.taskDescription ?? "")
                    .padding(.horizontal, 1)
                    
                
            }
            .padding(.leading, 8)
            .padding(.trailing, 14)
        }
        .background(statusGradient)
        .cornerRadius(12)
    }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 0.5)
        )
    }
   
}
