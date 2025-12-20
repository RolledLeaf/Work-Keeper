import Foundation

struct ClientDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let owner_id: UUID
    let first_name: String
    let last_name: String?
    let phone: String
    let comment: String?
    let created_at: Date?
    let updated_at: Date?
    let deleted_at: Date?
}

// insert
struct ClientInsertDTO: Codable {
    let owner_id: UUID
    let first_name: String
    let last_name: String?
    let phone: String
    let comment: String?
}

// update (редактирование)
struct ClientUpdateDTO: Codable {
    let first_name: String
    let last_name: String?
    let phone: String
    let comment: String?
}
