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
    extension View {
        @ViewBuilder
        func ifAvailableGlassStyle(in shape: some Shape, interactive: Bool = false) -> some View {
            if #available(iOS 26.0, *) {
                self.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
            } else {
                // Фоллбек для старых iOS (примерный “glass” через Material)
                self.background {
                    shape.fill(.ultraThinMaterial)
                }
            }
        }
    }

