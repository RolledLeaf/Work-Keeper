import SwiftUI


struct ScheduleTaskNotificationView: View {
    @Binding var taskDescription: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            HStack {
                
            Text("\(taskDescription)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
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
                    .multilineTextAlignment(.center)
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
                    .multilineTextAlignment(.center)
        }
            
            HStack {
                Text("Удалено")
                    .font(.custom(SFPro.regular.rawValue, size: 20))
                    .foregroundColor(Color.custom(.costPaymentRed))
                Image(systemName: "xmark.bin")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 5)
                    .foregroundStyle(.costPaymentRed)
            }
            
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
                    .multilineTextAlignment(.center)
        }
            
            Text("Отредактировано")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.textTitleGray))
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
                .multilineTextAlignment(.center)
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



struct AddClientNotificationView: View {
    @Binding var name: String
    
  
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("Клиент ")
                .font(.custom(SFPro.regular.rawValue, size: 20))
            
            HStack {
              
            Text("\(name)")
                .font(.custom(SFPro.bold.rawValue, size: 20))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
            
            Text("Добавлен")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(.primary)

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

struct EditClientNotificationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            
            Text("Клиент ")
                .font(.custom(SFPro.regular.rawValue, size: 20))
            
            HStack {
                
            Text("\(name)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
        }
            
            Text("Отредактирован")
                 .font(.custom(SFPro.regular.rawValue, size: 20))
                 .foregroundColor(Color.custom(.textTitleGray))
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

struct DeleteClientNotificationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            
            
            Text("Клиент ")
                .font(.custom(SFPro.regular.rawValue, size: 20))
            
            HStack {
                
            Text("\(name)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
        }
            
            HStack {
                Text("Удалён")
                    .font(.custom(SFPro.regular.rawValue, size: 20))
                    .foregroundColor(Color.custom(.costPaymentRed))
                Image(systemName: "xmark.bin")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 5)
                    .foregroundStyle(.costPaymentRed)
            }
            
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


struct AddStreetNotificationView: View {
    @Binding var streetName: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Адрес")
                .font(.headline)
                .foregroundColor(.primary)

            Text(streetName)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text("Успешно добавлена")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

struct DeleteStreetNotificationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 8) {
            
            
            
            Text("Адрес")
                .font(.custom(SFPro.regular.rawValue, size: 20))
            
            HStack {
                
            Text("\(name)")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
        }
            
            HStack {
                Text("Удалён")
                    .font(.custom(SFPro.regular.rawValue, size: 20))
                    .foregroundColor(Color.custom(.costPaymentRed))
                Image(systemName: "xmark.bin")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 5)
                    .foregroundStyle(.costPaymentRed)
            }
            
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

struct EditStreetNotificationView: View {
    @Binding var oldStreetName: String
    @Binding var streetName: String
    

    var body: some View {
        VStack(spacing: 8) {
            Text("Адрес")
                .font(.headline)
                .foregroundColor(.primary)

            Text(oldStreetName)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text("Изменён на ")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(streetName)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

