import SwiftUI

enum TaskToastKind {
    case scheduled, canceled, deleted, edited, completed

    var label: String {
        switch self {
        case .scheduled: return "Запланировано"
        case .canceled:  return "Отменено"
        case .deleted:   return "Удалено"
        case .edited:    return "Изменено"
        case .completed: return "Выполнено"
        }
    }

    var color: Color {
        switch self {
        case .scheduled: return Color.custom(.taskViewYellow)
        case .canceled:  return Color.custom(.taskCanceledOrange)
        case .deleted:   return Color.custom(.costPaymentRed)
        case .edited:    return Color.custom(.deepBlue)
        case .completed: return Color.custom(.taskCompleteGreen)
        }
    }

    var showsAmount: Bool { self == .completed }
}
 

struct TaskToastView: View {
    let kind: TaskToastKind
    let taskDescription: String
    var finalAmount: Double? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 15) {

                HStack {
                    Text("Задание")
                        .foregroundStyle(Color.custom(.pitchBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                    Spacer()
                }

                HStack {
                    Text("«")
                        .foregroundStyle(Color.custom(.pitchBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                    +
                    Text(taskDescription)
                        .font(.custom(Montserrat.regular.rawValue, size: 17))
                        .foregroundColor(Color.custom(.pitchBlack))

                    Text("»")
                        .foregroundStyle(Color.custom(.pitchBlack))
                        .font(.custom(Montserrat.extraBold.rawValue, size: 17))
                        .offset(x: -6)

                    Spacer()
                }
                .lineLimit(1, reservesSpace: false)

                HStack {
                    Text(kind.label)
                        .font(.custom(Montserrat.extraBold.rawValue, size: 24))
                        .foregroundColor(kind.color)

                    if kind.showsAmount, let amount = finalAmount {
                        Text("\(amount > 0 ? "+" : "") \(amount.formattedCurrency())")
                            .font(.custom(SFPro.bold.rawValue, size: 25))
                            .foregroundColor(
                                amount > 0
                                ? Color(CustomColor.taskCompleteGreen.rawValue)
                                : Color(CustomColor.costPaymentRed.rawValue)
                            )
                    }

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

