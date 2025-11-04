import SwiftUI


struct ScheduleTaskNotificationView: View {
    @Binding var taskDescription: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
        }
            
            Text("Запланировано")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.taskViewYellow))
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

struct CancelTaskNotificationView: View {
    @Binding var taskDescription: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
        }
            
            Text("Отменено")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.taskCanceledOrange))
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}


struct DeleteTaskNotificationView: View {
    @Binding var taskDescription: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
        }
            
            Text("Удалено")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.costPaymentRed))
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

struct EditTaskNotificationView: View {
    @Binding var taskDescription: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
        }
            
            Text("Отредактировано")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.taskCanceledOrange))
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

struct CompleteTaskNotificationView: View {
    @Binding var taskDescription: String
    @Binding var finalAmount: Double
  
    
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                .font(.custom(SFPro.bold.rawValue, size: 20))
                .foregroundColor(.primary)
        }
            
            Text("Выполнено")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(.primary)

            Text("+ \(finalAmount.formattedCurrency())")
                .font(.custom(SFPro.bold.rawValue, size: 25))
                .foregroundColor(Color(CustomColor.extraPaymentGreen.rawValue))
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}



