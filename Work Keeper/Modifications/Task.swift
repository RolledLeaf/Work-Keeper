import Foundation

extension Task {
    var status: Status {
        get {
            Status(rawValue: statusString ?? "") ?? .scheduled
        }
        set {
            statusString = newValue.rawValue
        }
    }
}


extension Task {
    var payment: PaymentType {
        get { PaymentType(rawValue: paymentType ?? "" ) ?? .none }
        set { paymentType = newValue.rawValue }
    }
}

