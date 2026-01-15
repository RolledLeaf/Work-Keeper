import Foundation

// То, что приходит/уходит в Supabase (таблица streets)
struct StreetDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let owner_id: UUID
    let name: String
    let created_at: Date?
    let updated_at: Date?
    let deleted_at: Date?
}

// То, что мы отправляем при insert
struct StreetInsertDTO: Codable {
    let owner_id: UUID
    let name: String
}

// То, что отправляем при update (soft delete)
struct StreetUpdateDTO: Codable {
    let deleted_at: Date
}
