import SwiftUI

struct StreetsListView: View {
    @State private var showAddStreetView = false
    @State private var sortToggle: Bool = false
    @ObservedObject var viewModel: StreetListViewModel
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        Spacer()
            .frame(height: 20)
        VStack {
            Text("Адрес")
           
            
            HStack {
                Button(action: {
                    switch sortToggle {
                    case true:
                        sortToggle = false
                        viewModel.loadSortedStreets(ascending: true)
                    case false:
                        sortToggle = true
                        viewModel.loadSortedStreets(ascending: false)
                    }
                   
                }) {
                    if sortToggle {
                        Image("sortZA")
                    } else {
                        Image("sortAZ")
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showAddStreetView = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 25, height: 25)
                }
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
                        .fill(Color.custom(.searchFieldGray))
                )
                .padding(.horizontal, 13)
            
            if viewModel.streets.isEmpty {
                
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
                List(viewModel.streets) { street in
                    StreetRow(
                        viewModel: viewModel, street: street
                    )

                    .onTapGesture {
                        viewModel.pickStreet(street)
                        dismiss()
                        print("selected street: \(street)")
                    }
                }
                
                .listStyle(PlainListStyle())
                .padding(.horizontal, 10)
                // убирает отступы List'а
            }
            Spacer()
        }
        .onAppear {
            viewModel.loadStreets()
        }
        
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showAddStreetView, onDismiss: {
            viewModel.loadStreets()
        }) {
            AddStreetView(viewModel: viewModel)
        }
    }
     
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
