import SwiftUI

struct StreetsListView: View {
    @State private var showAddStreetView = false
    @State private var sortToggle: Bool = false
    @ObservedObject var viewModel: StreetListViewModel
    @Environment(\.dismiss)
    private var dismiss
    
    private func loadUserDefaults() {
        if userDefaults.bool(forKey: UserDefaultsKeys.streetsSorting.rawValue) {
            sortToggle = true
            viewModel.loadSortedStreets(ascending: false)
        } else {
            viewModel.loadSortedStreets(ascending: true)
        }
    }
    
    var body: some View {
     
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    
                    Text("Отмена")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                }
                .padding(.top, 20)
                .padding(.leading, 15)
                .tint(.black)
                
                Spacer()
                Text("Список улиц")
                    .font(.custom(SFPro.bold.rawValue, size: 20))
                    .padding(.trailing, 30)
                    .offset(y: 30)
                Spacer()
            }
           
            
            HStack {
                Button(action: {
                    switch sortToggle {
                    case true:
                        sortToggle = false
                        viewModel.loadSortedStreets(ascending: true)
                        userDefaults.removeObject(forKey: UserDefaultsKeys.streetsSorting.rawValue)
                    case false:
                        sortToggle = true
                        viewModel.loadSortedStreets(ascending: false)
                        userDefaults.set(true, forKey: UserDefaultsKeys.streetsSorting.rawValue)
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
            .padding(.top, 20)
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
                Spacer()
                    .frame(height: 40)
                VStack {
                  
                    Image("noAddressPlaceholder")
                  
                    
                    Text("Адресов пока нет")
                        .font(.custom(SFPro.bold.rawValue, size: 30))
                }
            Spacer()
                
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
                Spacer()
            }
           
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
