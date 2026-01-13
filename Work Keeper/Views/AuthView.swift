import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Work Keeper")
                .font(.title)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let err = auth.authError {
                Text(err).foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                Button("Sign Up") {
                    Task {
                        isLoading = true
                        await auth.signUp(email: email, password: password)
                        isLoading = false
                    }
                }
                .buttonStyle(.bordered)

                Button("Log In") {
                    Task {
                        isLoading = true
                        await auth.signIn(email: email, password: password)
                        isLoading = false
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .disabled(isLoading || email.isBlank || password.isBlank)

            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}

