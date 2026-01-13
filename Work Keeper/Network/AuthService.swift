import Foundation
import CoreData
import Supabase

@MainActor
final class AuthService: ObservableObject {
    enum AuthState: Equatable {
        case loading
        case authenticated
        case unauthenticated
    }

    @Published private(set) var state: AuthState = .loading
    @Published private(set) var session: Session?
    @Published var authError: String?

    init() {}

    private let client = SupabaseManager.shared.client

    /// Optional hook to purge local (CoreData) data on logout.
    /// Set this from a higher-level composition root (e.g. App / RootView) where you have access to the context.
    var purgeLocalDataHandler: (() -> Void)?

    private func clearSyncCheckpoints(for ownerId: UUID) {
        // Per-owner keys introduced for multi-account safety
        UserDefaults.standard.removeObject(forKey: SyncKeys.lastPullAt(ownerId: ownerId))
        UserDefaults.standard.removeObject(forKey: SyncKeys.lastPushAtStreets(ownerId: ownerId))
        UserDefaults.standard.removeObject(forKey: SyncKeys.lastPushAtClients(ownerId: ownerId))
        UserDefaults.standard.removeObject(forKey: SyncKeys.lastPushAtAddresses(ownerId: ownerId))
        UserDefaults.standard.removeObject(forKey: SyncKeys.lastPushAtTasks(ownerId: ownerId))
    }
    
    var userId: UUID? {
        session?.user.id
    }
    
    var userEmail: String? {
        session?.user.email
    }
    
    func restoreSession() async {
        // Restore saved session if present. Missing/expired session is not a user-facing error.
        state = .loading
        authError = nil
        do {
            session = try await client.auth.session
            state = .authenticated
            print("session is valid")
        } catch {
            session = nil
            state = .unauthenticated
            // Don't set authError here. This is expected for logged-out users.
            // Supabase SDK error types can vary by module/version, so log generically.
            let nsError = error as NSError
            print("ℹ️ Auth restore: \(nsError.domain) code=\(nsError.code) \(nsError.localizedDescription)")
        }
    }

    func signUp(email: String, password: String) async {
        authError = nil
        do {
          
            let redirectURL = URL(string: "workkeeper://auth/callback")

            let result = try await client.auth.signUp(
                email: email,
                password: password,
                redirectTo: redirectURL
            )

            session = result.session
            state = (session == nil) ? .unauthenticated : .authenticated
        } catch {
            authError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        authError = nil
        do {
            let s: Session = try await client.auth.signIn(email: email, password: password)
            session = s
            state = .authenticated
        } catch {
            authError = error.localizedDescription
            state = .unauthenticated
        }
    }

    func signOut() async {
        authError = nil
        let ownerId = session?.user.id
        do {
            try await client.auth.signOut()

            session = nil
            state = .unauthenticated

 
            if let ownerId {
                clearSyncCheckpoints(for: ownerId)
            }

            // Purge local CoreData (optional, provided by composition root).
            purgeLocalDataHandler?()
        } catch {
            authError = error.localizedDescription
        }
    }


    func handleOpenURL(_ url: URL) {
        client.auth.handle(url)

        Task { [weak self] in
            guard let self else { return }
            await self.restoreSession()
        }
    }
}
