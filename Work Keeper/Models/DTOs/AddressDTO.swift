import Foundation

struct AddressDTO: Codable, Identifiable, Equatable {
    let id: UUID
    let owner_id: UUID
    let client_id: UUID
    let street_id: UUID

    let house: String
    let apartment: String?
    let entrance: String?
    let entrance_type: String?
    let room_type: String?
    let floor: String?
    let note: String?

    let is_primary: Bool
    let is_private_house: Bool

    let created_at: Date?
    let updated_at: Date?
    let deleted_at: Date?
}

struct AddressInsertDTO: Codable {
    let owner_id: UUID
    let client_id: UUID
    let street_id: UUID

    let house: String
    let apartment: String?
    let entrance: String?
    let entrance_type: String?
    let room_type: String?
    let floor: String?
    let note: String?

    let is_primary: Bool
    let is_private_house: Bool
}

struct AddressUpdateDTO: Codable {
    let street_id: UUID
    let house: String
    let apartment: String?
    let entrance: String?
    let entrance_type: String?
    let room_type: String?
    let floor: String?
    let note: String?
    let is_primary: Bool
    let is_private_house: Bool
}
