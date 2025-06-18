import SwiftUI

struct ClientRow: View {
    let client: Client
  
    
    var body: some View {
        ZStack {
            Color.custom(.newTaskBackgroundGray)?.ignoresSafeArea()
                
            
            let initials = (client.firstName.prefix(1) + (client.lastName?.prefix(1) ?? ""))
            
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.random()) // свой метод
                        .frame(width: 57, height: 57)
                    Text("\(initials.uppercased())")
                        .font(.custom(SFPro.bold.rawValue, size: 24))
                        .foregroundColor(.white)
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskInProgressYellow))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                        Text("\(1)")
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                    }
                    .offset(x: 22, y: -25)
                }
                .padding(.leading, 8)
                
                VStack {
                    Text("\(client.firstName) \(client.lastName ?? "")")
                        .font(.custom(SFPro.bold.rawValue, size: 24))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 25, alignment: .center)
                    Spacer()
                    Text("\(client.phoneNumber)")
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 20, alignment: .center)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.custom(.taskTextGray))
                        .offset(y: 4)
                    Spacer()
                    Text("\(client.address?.street ?? "Адрес не указан") \(client.address?.houseNumber ?? "")")
                        .font(.custom(SFPro.regular.rawValue, size: 17))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(height: 34, alignment: .center)
                        .lineLimit(2, reservesSpace: false)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)

                }
                .padding(.leading, 17)
                Spacer()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.completedtasksGreen))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                        Text("\(2)")
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskCanceledOrange))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                        Text("\(1)")
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.trailing, 10)
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
            )
        .padding(.vertical, 8)
        .cornerRadius(12)
    
    }
}

#Preview {
    ClientsListView()
}
