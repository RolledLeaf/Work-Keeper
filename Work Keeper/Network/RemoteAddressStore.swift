import Foundation
import Supabase

final class RemoteAddressStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

    func fetchByClient(clientId: UUID) async throws -> [AddressDTO] {
        let result: [AddressDTO] = try await client
            .from("addresses")
            .select()
            .eq("client_id", value: clientId.uuidString)
            .order("is_primary", ascending: false)
            .order("updated_at", ascending: false)
            .execute()
            .value
        return result
    }

    // MARK: - Create

    func create(_ payload: AddressInsertDTO) async throws -> AddressDTO {
        // IMPORTANT: never insert with is_primary = true directly.
        // It can violate the unique constraint (one primary per client) before we get a chance to run RPC.
        let safeInsert = AddressInsertDTO(
            owner_id: payload.owner_id,
            client_id: payload.client_id,
            street_id: payload.street_id,
            house: payload.house,
            apartment: payload.apartment,
            entrance: payload.entrance,
            entrance_type: payload.entrance_type,
            room_type: payload.room_type,
            floor: payload.floor,
            is_primary: false,
            is_private_house: payload.is_private_house
        )

        let created: AddressDTO = try await client
            .from("addresses")
            .insert(safeInsert)
            .select()
            .single()
            .execute()
            .value

        if payload.is_primary {
            try await setPrimary(clientId: payload.client_id, addressId: created.id)
        }

        return try await fetchOne(addressId: created.id)
    }

    // MARK: - Update

    func update(addressId: UUID, clientId: UUID, payload: AddressUpdateDTO) async throws -> AddressDTO {
        // IMPORTANT: never update with is_primary = true directly.
        // Update the fields first with is_primary = false, then set primary via RPC if needed.
        let safeUpdate = AddressUpdateDTO(
            street_id: payload.street_id,
            house: payload.house,
            apartment: payload.apartment,
            entrance: payload.entrance,
            entrance_type: payload.entrance_type,
            room_type: payload.room_type,
            floor: payload.floor,
            is_primary: false,
            is_private_house: payload.is_private_house
        )

        _ = try await client
            .from("addresses")
            .update(safeUpdate)
            .eq("id", value: addressId.uuidString)
            .execute()

        if payload.is_primary {
            try await setPrimary(clientId: clientId, addressId: addressId)
        }

        return try await fetchOne(addressId: addressId)
    }

    // MARK: - Soft delete (RPC)

    func softDelete(addressId: UUID) async throws {
        struct Params: Encodable { let p_address_id: UUID }

        let updatedCount: Int = try await client
            .rpc("soft_delete_address", params: Params(p_address_id: addressId))
            .execute()
            .value

        if updatedCount == 0 {
            throw NSError(
                domain: "RemoteAddressStore",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Address was not deleted (owner mismatch or already deleted)."]
            )
        }
    }

    // MARK: - Helpers

    private func fetchOne(addressId: UUID) async throws -> AddressDTO {
        try await client
            .from("addresses")
            .select()
            .eq("id", value: addressId.uuidString)
            .single()
            .execute()
            .value
    }

    private func setPrimary(clientId: UUID, addressId: UUID) async throws {
        struct Params: Encodable { let p_client_id: UUID; let p_address_id: UUID }

        let updatedCount: Int = try await client
            .rpc("set_primary_address", params: Params(p_client_id: clientId, p_address_id: addressId))
            .execute()
            .value

        if updatedCount == 0 {
            throw NSError(
                domain: "RemoteAddressStore",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to set primary address (not found / owner mismatch)."]
            )
        }
    }
}
