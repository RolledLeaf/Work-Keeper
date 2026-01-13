import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessagePresented = false
    
    private func showErrorTemporarily() {
        errorMessagePresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.25)) {
                errorMessagePresented = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Вход")
                    .font(.custom(Montserrat.medium.rawValue, size: 22))
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    if errorMessagePresented, let err = auth.authError {
                        Text(err)
                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .frame(height: 12)
                
                HStack(spacing: 12) {
                    Spacer()
                    Button("Log In") {
                        Task {
                            isLoading = true
                            await auth.signIn(email: email, password: password)
                            isLoading = false
                        }
                    }
                    Spacer()
                }
                .disabled(isLoading || email.isBlank || password.isBlank)
                
                HStack {
                    Text("Нет профиля? Зарегистрируйтесь")
                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                    Spacer()
                    
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Sign Up")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                }
                if isLoading {
                    ProgressView()
                }
                
            }
            .padding()
            .onChange(of: auth.authError) { _, newValue in
                guard newValue != nil else { return }
                withAnimation(.easeIn(duration: 0.15)) {
                    errorMessagePresented = true
                }
                showErrorTemporarily()
            }
            
        }
        .onTapGesture { hideKeyboard() }

    }
}
