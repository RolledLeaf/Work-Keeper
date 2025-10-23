import SwiftUI

struct StreetsListView: View {
    @State private var showAddStreetView = false
    @State private var sortToggle: Bool = false
    @ObservedObject var viewModel: StreetListViewModel
    @Environment(\.dismiss)
    private var dismiss
    
    func loadUserDefaults() {
        if userDefaults.bool(forKey: UserDefaultKeys.streetsSorting.rawValue) {
            sortToggle = true
            viewModel.loadSortedStreets(ascending: false)
        } else {
            viewModel.loadSortedStreets(ascending: true)
        }
    }
    
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
                        userDefaults.removeObject(forKey: UserDefaultKeys.streetsSorting.rawValue)
                    case false:
                        sortToggle = true
                        viewModel.loadSortedStreets(ascending: false)
                        userDefaults.set(true, forKey: UserDefaultKeys.streetsSorting.rawValue)
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
            
            HStack {
            TextField("Начните вводить адрес", text: $viewModel.searchText)
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
                
            if !viewModel.searchText.isEmpty {
                Button(action:  {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 25, height: 25)
                        
                }
                
            }
        }
            .padding(.horizontal, 13)
            
            
            if viewModel.streets.isEmpty {
               
                VStack {
                    Spacer()
                        .frame(height: 40)
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
            loadUserDefaults()
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
