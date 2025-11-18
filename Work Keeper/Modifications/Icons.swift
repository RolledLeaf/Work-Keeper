import SwiftUI

extension View {
    @ViewBuilder
    func ifAvailableButtonStyleGlass() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }
}
