import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthService()

    var body: some View {
        Group {
            if auth.session == nil {
                AuthView()
                    .environmentObject(auth)
            } else {
                TabBar() 
            }
        }
        .task {
            await auth.restoreSession()
        }
    }
}
