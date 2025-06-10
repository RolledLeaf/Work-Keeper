import Foundation

enum Status: String, Codable {
    case scheduled
    case completed
    case canceled
}

enum PaymentMethod: String, Codable {
    case creditCard
    case cash
}
