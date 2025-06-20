import SwiftUI

enum CustomColor: String {
    case cancelButtonRed = "cancelButtonRed"
    case taskCanceledOrange = "taskCanceledOrange"
    case taskCompleteGreen = "taskCompleteGreen"
    case taskInProgressYellow = "taskInProgressYellow"
    case inactiveButtonGray = "inactiveButtonGray"
    case newTaskBackgroundGray = "newTaskBackgroundGray"
    case searchFieldGray = "searchFieldGray"
    case taskCellGray = "taskCellGray"
    case taskInfoGray = "taskInfoGray"
    case taskTextGray = "taskTextGray"
    case extraPaymentGreen = "extraPaymentGreen"
    case costPaymentRed = "costPaymentRed"
}

extension Color {
    static func custom(_ color: CustomColor) -> Color? {
        return Color(color.rawValue)
    }
}
