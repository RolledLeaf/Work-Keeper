import SwiftUI

struct NewClientView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case firstName
        case lastName
    }
    
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }
            VStack {
                Text("Новый клиент")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(Color.black)
                
                Spacer()
                    .frame(height: 70)
                
                ZStack {
                    Color.white
                        .cornerRadius(12)
                    
                    VStack {
                        
                        TextField("Имя", text: $firstName)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .padding(.leading, 11)
                            .background(Color.clear)
                            .focused($focusedField, equals: .firstName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .lastName
                            }

                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color.custom(.strokeGray))
                            .padding(.leading, 11)
                            .padding(.trailing, 10)

                        TextField("Фамилия (не обязательно)", text: $lastName)
                            .font(.system(size: 19, weight: .regular, design: .default))
                            .padding(.leading, 11)
                            .padding(.top, 5)
                            .background(Color.clear)
                            .focused($focusedField, equals: .lastName)
                            .submitLabel(.done)
                            .onSubmit {
                                hideKeyboard()
                            }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                    
                        .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                    )
                .padding(.vertical, 8)
                .cornerRadius(12)
                .padding(.leading, 20)
                .padding(.trailing, 15)
                .frame(height: 110, alignment: .center)
                
                
                Spacer()
                
                Text("Hello, World!")
            }
        }
    }
}


#Preview {
    NewClientView()
}
