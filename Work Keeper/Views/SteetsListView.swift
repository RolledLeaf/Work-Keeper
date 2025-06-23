import SwiftUI


private let streets: [String] = ["Академика Пилюгина", "Академика Янгеля", "Березина", "Высоцкого", "Герцина" , "Железнодорожный проезд"]
//private let addresses = ["Академика Пилюгина", "Академика Янгеля", "Березина", "Высоцкого", "Герцина" , "Железнодорожный проезд"]

struct StreetsListView: View {
    var body: some View {
        Spacer()
            .frame(height: 20)
        VStack {
            Text("Адрес")
           
            
            HStack {
                Image("sortAZ")
                
                Spacer()
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .padding(.leading, 27)
            .padding(.trailing, 20)
            
            Spacer()
                .frame(height: 15)
            
            TextField("Начните вводить адрес", text: .constant(""))
                .padding(9)
                .padding(.leading, 25)
                .onTapGesture {
                    hideKeyboard()
                }
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
                .padding(.horizontal, 13)
            
            if streets.isEmpty {
                
                VStack {
                    Spacer()
                        .frame(height: 123)
                    Image("noAddressPlaceholder")
                    Spacer()
                        .frame(height: 51)
                    
                    Text("Адресов пока нет")
                        .font(.custom(SFPro.bold.rawValue, size: 30))
                }
            } else {
                Spacer()
                    .frame(height: 40)
                List(streets.indices, id: \.self) { index in
                    let street = streets[index]
                    let isFirst = index == streets.startIndex
                    let isLast = index == streets.endIndex - 1

                    StreetRow(
                        street: street,
                        isFirst: isFirst,
                        isLast: isLast
                    )
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal, 10)
                // убирает отступы List'а
            }
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
      
}

#Preview {
    StreetsListView()
}
