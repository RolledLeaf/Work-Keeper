import SwiftUI

struct AddStreetView: View {
    
    private let maxStreetCharactersCount: Int = 44
    @State private var streetName: String = ""
    @State private var maxStreetCharactersTextOpacity: Double = 0
    @State var saveColor: Color = .gray
    @State var saveButtomOpacity: Double = 0
    
    @ObservedObject  var viewModel: StreetListViewModel
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
       
        
        VStack {
            HStack {
                Spacer()
            Text("Новая улица")
                .font(.custom(SFPro.bold.rawValue, size: 20))
                .padding(.trailing, 30)
                .offset(y: 30)
              
                Button(action: {
                    if !streetName.isBlank {
                        viewModel.addStreet(streetName)
                        dismiss()
                    }
                }) {
                   
                        Text("Сохранить")
                        .font(.custom(SFPro.regular.rawValue, size: 15))
                            .frame(height: 60)
                            .opacity(saveButtomOpacity)
                            .frame(width: 100, height: 40)
                            .tint(saveColor)
                            .onChange(of: streetName) {
                                if !streetName.isBlank {
                                    saveButtomOpacity = 1
                                    saveColor = .black
                                    
                                } else {
                                        
                                    saveButtomOpacity = 0
                                    }
                            }
                            
                    
                }
                .padding(.top, 20)
        }
            Spacer()
                .frame(height: 38)
            
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
                        .fill(Color.custom(.searchFieldGray) ?? .searchFieldGray)
                        .padding(.horizontal, 15)
                )
            
            Text("максимум символов \(maxStreetCharactersCount)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .opacity(maxStreetCharactersTextOpacity)
            Spacer()
            
          
          
        }
        .onTapGesture {
            hideKeyboard()
        }
        
    }
    
       
}




