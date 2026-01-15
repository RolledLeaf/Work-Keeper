import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        switch auth.state {
        case .loading:
            SplashView()

        case .unauthenticated:
            LoginView()

        case .authenticated:
            TabBar()
        }
    }
}
