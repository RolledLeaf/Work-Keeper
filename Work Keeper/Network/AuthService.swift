import Foundation
import Supabase

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var session: Session?
    @Published var authError: String?

    private let client = SupabaseManager.shared.client
    
    var userId: UUID? {
        session?.user.id
    }

    func restoreSession() async {
        // Поднимаем сохранённую сессию (если есть). В новых версиях SDK это async/throws.
        authError = nil
        do {
            session = try await client.auth.session
        } catch {
            // Если сессии нет или она невалидна — это не критическая ошибка.
            session = nil
            authError = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        authError = nil
        do {
            let result = try await client.auth.signUp(email: email, password: password)
            session = result.session
        } catch {
            authError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        do {
            let result = try await client.auth.signIn(email: email, password: password)
            session = result
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() async {
        authError = nil
        do {
            try await client.auth.signOut()
            session = nil
        } catch {
            authError = error.localizedDescription
        }
    }
}
