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
}

extension Color {
    static func custom(_ color: CustomColor) -> Color? {
        return Color(color.rawValue)
    }
}

extension Color {
    static func randomColor() -> Color {
        return Color(.sRGB, red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }
}
