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
                        .frame(width: 60, height: 60)
                    Text("\(initials.uppercased())")
                        .font(.custom(Montserrat.bold.rawValue, size: 24))
                        .foregroundColor(.white)
                    
                 
                }
                .padding(.leading, 13)
                
//                VStack(spacing: 10) {
                VStack {
                    Spacer()
                    HStack {
                        Text(highlighted(client.firstName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.bold.rawValue, size: 15))
                           
  
                        Text(highlighted(client.lastName?.uppercased() ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                            .font(.custom(Montserrat.bold.rawValue, size: 15))
                    }
                    .frame(maxWidth: 230, alignment: .leading)
                    .frame(maxHeight: 15, alignment: .center)
                    
                    
                    Text(highlighted(client.phone ?? "", query: viewModel.searchText, highlightColor: .highlightBlue))
                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 15, alignment: .center)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.custom(.taskTextGray))
                    
                    if !client.hasAddress {
                        HStack {
                            
                            Text("Клиент не давал адрес")
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                        }
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 230, alignment: .leading)
                            .frame(maxHeight: 15, alignment: .center)

                    } else {
                        
                        HStack {
                            
                            
                            Text(highlighted(client.primaryAddress?.street?.name ?? "Адрес не указан", query: viewModel.searchText, highlightColor: .highlightBlue))
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                                
                            
                            Text("\(client.primaryAddress?.house ?? "")")
                                .font(.custom(Montserrat.regular.rawValue, size: 15))
                        }
                        .frame(maxWidth: 230, alignment: .leading)
                        .frame(maxHeight: 15, alignment: .center)
                        .multilineTextAlignment(.leading)
                    }

                    Spacer()
                }
                .padding(.leading, 8)
                
                Spacer()
                
                VStack(spacing: 5) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskCompleteGreen))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.completedTasksCount > 0 ? 1 : 0)
                        Text("\(client.completedTasksCount)")
                            .font(.custom(Montserrat.regular.rawValue, size: 17))
                            .foregroundColor(.custom(.mainBlack))
                            .opacity(client.completedTasksCount > 0 ? 1 : 0)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskViewYellow))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.scheduledTasksCount > 0 ? 1 : 0)
                        Text("\(client.scheduledTasksCount)")
                            .font(.custom(Montserrat.regular.rawValue, size: 17))
                            .foregroundColor(.custom(.mainBlack))
                            .opacity(client.scheduledTasksCount > 0 ? 1 : 0)
                    }
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.custom(.taskCanceledOrange))
                            .cornerRadius(12)
                            .frame(width: 23, height: 23)
                            .opacity(client.canceledTasksCount > 0 ? 1 : 0)
                        Text("\(client.canceledTasksCount)")
                            .font(.custom(Montserrat.regular.rawValue, size: 17))
                            .foregroundColor(.custom(.mainBlack))
                            .opacity(client.canceledTasksCount > 0 ? 1 : 0)
                    }
                   
                }
                .padding(.trailing, 6)
                .padding(.vertical, 5)
            }
            .frame(height: 90)
//            .frame(maxHeight: 90)
            
            
        }

        .background(.ultraThickMaterial, in: .rect)
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
