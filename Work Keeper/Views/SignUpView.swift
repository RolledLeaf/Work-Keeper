import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessagePresented = false
    @State private var showConfirmationToast = false
    @State private var confirmationText = ""
    
   
    
    private func showErrorTemporarily() {
        errorMessagePresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.25)) {
                errorMessagePresented = false
            }
        }
    }
    
    
    var body: some View {
        let emailClean = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordClean = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        VStack(spacing: 16) {
            Text("Регистрация")
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
                    Button("Sign Up") {
                        Task {
                            isLoading = true
                            await auth.signUp(email: emailClean, password: passwordClean)
                            isLoading = false
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    
                }
                .disabled(isLoading || email.isBlank || password.isBlank)
            
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
                .onChange(of: auth.signUpPhase) { _, newValue in
                    if case let .confirmationEmailSent(email) = newValue {
                        confirmationText = "На \(email) отправлено письмо со ссылкой подтверждением."
                        withAnimation(.easeInOut) { showConfirmationToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut) { showConfirmationToast = false }
                        }
                    }
                }
        
                .overlay(alignment: .top) {
                    if showConfirmationToast {
                        Text(confirmationText)
                            .font(.custom(Montserrat.regular.rawValue, size: 12))
                            .multilineTextAlignment(.center)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .onAppear() {
                    hideKeyboard()
                }
        }
    }

