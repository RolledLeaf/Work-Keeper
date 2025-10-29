import SwiftUI

struct AddStreetConfirmationView: View {
    @Binding var streetName: String

    var body: some View {
        VStack(spacing: 8) {
            Text("Улица")
                .font(.headline)
                .foregroundColor(.primary)

            Text(streetName)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            Text("Успешно добавлена")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(maxWidth: 340)
    }
}

struct StreetsListView: View {
    @State private var showAddStreetView = false
    @State private var sortToggle: Bool = false
    @State private var showAddConfirmation = false
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
            
        .overlay(alignment: .center) {
            if showAddConfirmation {
               
                AddStreetConfirmationView(streetName: $viewModel.lastAddedStreetName)
                    .transition(.offset(y: 40).combined(with: .opacity))
                    
            }
            
        }
        
        .onAppear {
//            viewModel.loadStreets()
            loadUserDefaults()
        }
        
        .onTapGesture {
            hideKeyboard()
        }
        
        .sheet(isPresented: $showAddStreetView, onDismiss: {
            loadUserDefaults()
            guard !viewModel.lastAddedStreetName.isBlank else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                showAddConfirmation = true
        }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showAddConfirmation = false
                    viewModel.lastAddedStreetName = ""
                }
            }
                
        }) {
            AddStreetView(viewModel: viewModel)
        }
    }
     
}

#Preview {
    StreetsListView(viewModel: StreetListViewModel())
}
