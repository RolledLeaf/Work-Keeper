import SwiftUI

enum CustomColor: String {
    case cancelButtonRed = "cancelButtonRed"
    case taskCanceledOrange = "taskCanceledOrange"
    case taskCompleteGreen = "taskCompleteGreen"
    case taskViewYellow = "taskViewYellow"
    case inactiveButtonGray = "inactiveButtonGray"
    case newTaskBackgroundGray = "newTaskBackgroundGray"
    case searchFieldGray = "searchFieldGray"
    case taskCellGray = "taskCellGray"
    case taskInfoGray = "taskInfoGray"
    case taskTextGray = "taskTextGray"
    case extraPaymentGreen = "extraPaymentGreen"
    case costPaymentRed = "costPaymentRed"
    case strokeGray = "strokeGray"
    case completedTaskGreen = "completedTaskGreen"
    case editButtonGray = "editButtonGray"
    case deleteButtonRed = "deleteButtonRed"
    case textTitleGray = "textTitleGray"
    case addressListGray = "addressListGray"
    case separatorLineGray = "separatorLineGray"
    case inactiveFiledGray = "inactiveFiledGray"
    case pureWhite = "pureWhite"
    case taskViewGreen = "taskViewGreen"
    case greenStartPoint = "greenStartPoint"
    case greenEndPoint = "greenEndPoint"
    case yellowStartPoint = "yellowStartPoint"
    case yellowEndPoint = "yellowEndPoint"
    case orangeStartPoint = "orangeStartPoint"
    case orangeEndPoint = "orangeEndPoint"
    case highlightBlue = "highlightBlue"
    case pitchBlack = "pitchBlack"
    case mainBackground = "mainBackground"
    case scheduleCancelButton = "scheduleCancelButton"
    case mainBlack = "mainBlack"
    case bckgFieldGray = "bckgFieldGray"
    case whiteOnly = "whiteOnly"
    case inactiveColorsGray = "inactiveColorsGray"
    case splashBackground = "splashBackground"
    case deepBlue = "deepBlue"
}



extension Color {
    /// Возвращает осветлённую версию цвета.
    /// - Parameter percentage: Насколько осветлить цвет (0...1). 0 — без изменений, 1 — максимально к белому.
    func lightened(by percentage: CGFloat = 0.2) -> Color {
        let amount = max(0, min(percentage, 1))

        #if canImport(UIKit)
        // iOS, tvOS, watchOS
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return self
        }

        let newR = min(r + amount, 1)
        let newG = min(g + amount, 1)
        let newB = min(b + amount, 1)

        return Color(.sRGB, red: newR, green: newG, blue: newB, opacity: Double(a))

        #elseif canImport(AppKit)
        // macOS
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return self
        }

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        let newR = min(r + amount, 1)
        let newG = min(g + amount, 1)
        let newB = min(b + amount, 1)

        return Color(.sRGB, red: newR, green: newG, blue: newB, opacity: Double(a))

        #else
        // На всякий случай, если платформа не поддерживается
        return self
        #endif
    }
}

extension Color {
    static func randomColor() -> Color {
        return Color(.sRGB, red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}

extension Color {
    static func custom(_ color: CustomColor) -> Color {
        Color(color.rawValue)
    }
}
