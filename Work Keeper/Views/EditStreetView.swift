import SwiftUI

struct EditStreetView: View {
    private let maxStreetCharactersCount: Int = 49
    @State private var streetName: String = ""
    @State private var maxStreetCharactersTextOpacity: Double = 0
    @State var saveButtomOpacity: Double = 0
    var onEdit: ((String) -> Void)?
    
    @StateObject var viewModel: StreetListViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    let street: Street
    
    var body: some View {
        
        
        VStack {
            HStack {
                Button(action: {
                  
                    dismiss()
                }) {
                    Text("Отмена")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .tint(.black)
                }
                
                Spacer()
              
                
                Button(action: {
                    viewModel.update(street, name: streetName)
                    onEdit?(streetName)
                    dismiss()
                    print("Street updated with name: \(streetName)")
                }) {
                    Text("Сохранить")
                        
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                        .frame(width: 100, height: 40)
                        .tint(streetName.isBlank ? .inactiveButtonGray : .black)
                }
                .disabled(streetName.isBlank)
                
            }
            .padding(.leading, 10)
            .padding(.top, 5)
            
            Text("Изменение названия")
                .font(.custom(SFPro.bold.rawValue, size: 20))

                .padding(.top, 10)
                
            
            Spacer()
                .frame(height: 38)
            
            HStack {
            TextField("Введите название улицы", text: $streetName)
                .font(.system(size: 24, weight: .medium, design: .default))
                .onSubmit {
                    hideKeyboard()
                }
                .submitLabel(.done)
                .padding(.leading, 40)
                .padding(.trailing, 20)
                .frame(height: 75)
                .onChange(of: streetName) { newValue in
                    if newValue.count > maxStreetCharactersCount {
                        streetName = String(newValue.prefix(maxStreetCharactersCount))
                    }
                    if streetName.count >= maxStreetCharactersCount {
                        maxStreetCharactersTextOpacity = 1 } else {
                            maxStreetCharactersTextOpacity = 0
                        }
                    
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.custom(.searchFieldGray))
                        .padding(.horizontal, 15)
                )
            if !streetName.isEmpty {
                Button(action:  {
                    streetName = ""
                }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .offset(x: -10)
                }
                
            }
        }
            
            Text("максимум символов \(maxStreetCharactersCount)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .opacity(maxStreetCharactersTextOpacity)
            Spacer()
            
                .onAppear {
                    streetName = street.name ?? ""
                }
            
        }
        .onTapGesture {
            hideKeyboard()
        }
        
    }
    
}
