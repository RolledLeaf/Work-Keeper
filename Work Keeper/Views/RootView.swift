import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        switch auth.state {
        case .loading:
            ProgressView("Загрузка…")

        case .unauthenticated:
            AuthView()

        case .authenticated:
            TabBar()
        }
    }
}
