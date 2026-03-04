import Foundation

struct TaskDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let owner_id: UUID

    let scheduled_at: Date
    let task_description: String?
    let payment_type: String?
    let comment: String?

    let is_remote: Bool
    let is_at_my_place: Bool
    let statusString: String   // Swift-имя оставляем удобным

    let contract_amount: Double
    let cost: Double
    let extra_payment: Double?
    let total_amount: Double

    let client_id: UUID
    let address_id: UUID?

    let created_at: Date?
    let updated_at: Date?
    let deleted_at: Date?

    enum CodingKeys: String, CodingKey {
        case id, owner_id, scheduled_at, task_description, payment_type, comment
        case is_remote
        case is_at_my_place
        case statusString = "status"     // ✅ ВАЖНО: колонка в БД называется status
        case contract_amount, cost, extra_payment, total_amount
        case client_id, address_id
        case created_at, updated_at, deleted_at
    }
}

struct TaskInsertDTO: Codable {
    let owner_id: UUID
    let scheduled_at: Date
    let task_description: String?
    let payment_type: String?
    let comment: String?

    let is_remote: Bool
    let is_at_my_place: Bool
    let statusString: String   // Swift-имя

    let contract_amount: Double
    let cost: Double
    let extra_payment: Double?

    let client_id: UUID
    let address_id: UUID?

    enum CodingKeys: String, CodingKey {
        case owner_id, scheduled_at, task_description, payment_type, comment
        case is_remote
        case is_at_my_place
        case statusString = "status"     // ✅
        case contract_amount, cost, extra_payment
        case client_id, address_id
    }
}

struct TaskUpdateDTO: Codable {
    let scheduled_at: Date
    let task_description: String?
    let payment_type: String?
    let comment: String?

    let is_remote: Bool
    let is_at_my_place: Bool
    let statusString: String   // Swift-имя

    let contract_amount: Double
    let cost: Double
    let extra_payment: Double?

    let client_id: UUID
    let address_id: UUID?

    enum CodingKeys: String, CodingKey {
        case scheduled_at, task_description, payment_type, comment
        case is_remote
        case is_at_my_place
        case statusString = "status"     // ✅
        case contract_amount, cost, extra_payment
        case client_id, address_id
    }
}
