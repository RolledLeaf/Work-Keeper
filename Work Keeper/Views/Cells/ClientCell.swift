import SwiftUI

struct ClientRow: View {
    let client: Client
    @ObservedObject var viewModel: ClientsListViewModel
    
    
    var body: some View {
        
        let initials = ((client.firstName?.prefix(1) ?? "") + (client.lastName?.prefix(1) ?? ""))
        
       
        
        ZStack {
            Color.custom(.taskCellGray).ignoresSafeArea()
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.randomColor()) // свой метод
                        .frame(width: 57, height: 57)
                    Text("\(initials.uppercased())")
                        .font(.custom(Montserrat.bold.rawValue, size: 24))
                        .foregroundColor(.white)
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskViewYellow))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.scheduledTasksCount > 0 ? 1 : 0)
                        Text("\(client.scheduledTasksCount)")
                        .opacity(client.scheduledTasksCount > 0 ? 1 : 0)
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                            
                    }
                    .offset(x: 22, y: -25)
                }
                .padding(.leading, 8)
                
                VStack {
                    Text(highlighted(client.firstName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                        .font(.custom(Montserrat.bold.rawValue, size: 24))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 25, alignment: .center)
                        .padding(.top, 7)
                        
                    Spacer()
                    
                    if !client.hasAddress {
                        HStack {
                            
                            Text("Клиент не давал адрес")
                                .font(.custom(Montserrat.regular.rawValue, size: 19))
                        }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 230, alignment: .leading)
                            .frame(height: 34, alignment: .center)
                            
                            
                    } else {
                        
                        HStack {
                            
                            
                            Text(highlighted(client.primaryAddress?.street?.name ?? "Адрес не указан", query: viewModel.searchText, highlightColor: .highlightBlue))
                                .font(.custom(SFPro.regular.rawValue, size: 19))
                                .lineLimit(2, reservesSpace: false)
                            
                            Text("\(client.primaryAddress?.house ?? "")")
                                .font(.custom(SFPro.regular.rawValue, size: 19))
                        }
                        
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(height: 34, alignment: .center)
                        
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.leading)
                    }
                  
                    Spacer()
//                    Text(highlighted(client.phone?.formattedAsPhone() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                    Text(highlighted(client.phone ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                        .font(.custom(Montserrat.regular.rawValue, size: 16))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 20, alignment: .center)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.custom(.taskTextGray))
                        .padding(.bottom, 4)
                    
                }
                .padding(.leading, 17)
                
                Spacer()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.completedTaskGreen))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.completedTasksCount > 0 ? 1 : 0)
                        Text("\(client.completedTasksCount)")
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                            .opacity(client.completedTasksCount > 0 ? 1 : 0)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskCanceledOrange))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.canceledTasksCount > 0 ? 1 : 0)
                        Text("\(client.canceledTasksCount)")
                            .font(.custom(SFPro.regular.rawValue, size: 17))
                            .foregroundColor(.white)
                            .opacity(client.canceledTasksCount > 0 ? 1 : 0)
                    }
                    Spacer()
                }
                .padding(.trailing, 10)
                .padding(.vertical, 7)
            }
            .frame(height: 100)
            
            
        }
        .cornerRadius(left: 50, right: 15)
        .overlay {
            if #available(iOS 16.0, *) {
                TwoSideRoundedRectangle(leftRadius: 50, rightRadius: 15)
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.custom(.strokeGray), lineWidth: 0.5)
            }
        }
        
    }
}

#Preview {
    ClientsListView()
}
