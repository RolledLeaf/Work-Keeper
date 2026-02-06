import SwiftUI

enum ConfirmationStrings: String {
    case title = "Задание"
    case scheduled = "Запланировано"
    case deleted = "Удалено"
    case completed = "Выполнено"
    case canceled = "Отменено"
    case edited = "Изменено"
    case clientTitle = "Клиент"
    case clientDeleted = "Удален"
    
}
 

struct ScheduleTaskConfirmationView: View {
    @Binding var taskDescription: String
 
  
    var body: some View {
        ZStack {
        VStack(spacing: 15) {
            
            HStack {
                Text("\(ConfirmationStrings.title.rawValue)")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                Spacer()
            }
            
            HStack {
                
                Text("«")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                +
                Text("\(taskDescription)")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                    .foregroundColor(Color.custom(.mainBlack))
                +
                Text("»")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                Spacer()
            }
            
            HStack {
                Text("\(ConfirmationStrings.scheduled.rawValue)")
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    .foregroundColor(Color.custom(.taskViewYellow))
                    .multilineTextAlignment(.center)
                Spacer()
            }
           
        }
        .padding(16)
       
    }
        .background(Image("confirmationBackground"))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct CancelTaskConfirmationView: View {
    @Binding var taskDescription: String
 
  
    var body: some View {
        ZStack {
        VStack(spacing: 15) {
            
            HStack {
                Text("\(ConfirmationStrings.title.rawValue)")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                Spacer()
            }
            
            HStack {
                
                Text("«")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                +
                Text("\(taskDescription)")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                    .foregroundColor(Color.custom(.mainBlack))
                +
                Text("»")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                Spacer()
            }
            
            HStack {
                Text("\(ConfirmationStrings.canceled.rawValue)")
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    .foregroundColor(Color.custom(.taskCanceledOrange))
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .padding(16)
       
    }
        .background(Image("confirmationBackground"))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}


struct DeleteTaskConfirmationView: View {
    @Binding var taskDescription: String
 
  
    var body: some View {
        ZStack {
        VStack(spacing: 15) {
            
            HStack {
                Text("\(ConfirmationStrings.title.rawValue)")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                Spacer()
            }
            
            HStack {
                
                Text("«")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                +
                Text("\(taskDescription)")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                    .foregroundColor(Color.custom(.mainBlack))
                +
                Text("»")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                Spacer()
            }
            
            HStack {
                Text("\(ConfirmationStrings.deleted.rawValue)")
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    .foregroundColor(Color.custom(.costPaymentRed))
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .padding(16)
       
    }
        .background(Image("confirmationBackground"))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct EditTaskConfirmationView: View {
    @Binding var taskDescription: String
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                
                HStack {
                    Text("\(ConfirmationStrings.title.rawValue)")
                        .foregroundStyle(Color.custom(.mainBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    Spacer()
                }
                
                HStack {
                    
                    Text("«")
                        .foregroundStyle(Color.custom(.mainBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                    +
                    Text("\(taskDescription)")
                        .font(.custom(Montserrat.regular.rawValue, size: 17))
                        .foregroundColor(Color.custom(.mainBlack))
                    +
                    Text("»")
                        .foregroundStyle(Color.custom(.mainBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                    Spacer()
                }
                
                HStack {
                    Text("\(ConfirmationStrings.edited.rawValue)")
                        .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                        .foregroundColor(Color.custom(.deepBlue))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
            .padding(16)
            
        }
        .background(Image("confirmationBackground"))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct CompleteTaskConfirmationView: View {
    @Binding var taskDescription: String
    @Binding var finalAmount: Double
    let confirmationTitle = "Задание"
   
    var body: some View {
        ZStack {
        VStack(spacing: 16) {
            HStack {
                Text("\(confirmationTitle)")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                Spacer()
            }
            
            
            HStack {
                Text("«")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                +
                Text("\(taskDescription)")
                    .font(.custom(Montserrat.regular.rawValue, size: 17))
                    .foregroundColor(.primary)
                +
                Text("»")
                    .foregroundStyle(Color.custom(.mainBlack))
                    .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                Spacer()
            }
            HStack {
                Text("Выполнено")
                    .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    .foregroundColor(Color.custom(.taskCompleteGreen))
                
                
                Text("\(finalAmount > 0 ? "+" : "") \(finalAmount.formattedCurrency())")
                    .font(.custom(SFPro.bold.rawValue, size: 25))
                    .foregroundColor(finalAmount > 0 ? Color(CustomColor.taskCompleteGreen.rawValue) : Color(CustomColor.costPaymentRed.rawValue))
                Spacer()
            }
            
        }
        .padding(16)
       
    }
        .background(Image("confirmationBackground"))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}



struct AddClientConfirmationView: View {
    @Binding var name: String

    var body: some View {
        VStack(spacing: 15) {
            
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
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct EditClientConfirmationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 15) {
            
            
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
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct DeleteClientConfirmationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 15) {
            
            
            
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
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}


struct AddStreetConfirmationView: View {
    @Binding var streetName: String

    var body: some View {
        VStack(spacing: 15) {
            Text("Адрес")
                .font(.headline)
                .foregroundColor(.primary)

            Text(streetName)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text("Успешно добавлен")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        .padding(16)
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct DeleteStreetConfirmationView: View {
    @Binding var name: String
  
    var body: some View {
        VStack(spacing: 15) {
            
            
            
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
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

struct EditStreetConfirmationView: View {
    @Binding var oldStreetName: String
    @Binding var streetName: String
    

    var body: some View {
        VStack(spacing: 15) {
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
        .background(Color.custom(.mainBackground).lightened(by: 0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(height: 170)
        .frame(maxWidth: 340)
    }
}

