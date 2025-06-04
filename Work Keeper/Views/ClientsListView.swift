import SwiftUI

struct ClientsListView: View {
    var body: some View {
        ZStack {
            Color.custom(.newTaskBackgroundGray)?.ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        //action
                    }) {
                        Image("sortAZ")
                            .resizable()
                            .frame(width: 31, height: 22)
                    }
                    .padding(.leading, 3)
                    
                    Spacer()
                    
                    Button(action: {
                        //action
                    }) {
                        Image("addClientButton")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    .padding(.trailing, 5)
                }
                
                TextField("Поиск клиента", text: .constant(""))
                    .padding(9)
                    .padding(.leading, 25)
                    .background(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        Spacer()
                    })
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.custom(.searchFieldGray) ?? .searchFieldGray)
                    )
                    .padding(.leading, 1)
                    .padding(.trailing, 1)
                
                Spacer()
                    .frame(height: 165)
                
                Image("noClientsPlaceholder")
                    .resizable()
                    .frame(width: 276, height: 268)
                
                Text("Клиентов пока нет")
                    
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.trailing, 15)
            .padding(.leading, 20)
        }
    }
}

#Preview {
    ClientsListView()
}
