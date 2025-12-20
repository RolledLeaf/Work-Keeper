import Foundation
import Supabase

final class RemoteClientStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

    func fetchAll(ownerId: UUID) async throws -> [ClientDTO] {
        let result: [ClientDTO] = try await client
            .from("clients")
            .select()
            .order("first_name", ascending: true)
            .execute()
            .value

        return result.filter { $0.owner_id == ownerId }
    }

    // MARK: - Create

    func create(
        firstName: String,
        lastName: String?,
        phone: String,
        comment: String?,
        ownerId: UUID
    ) async throws -> ClientDTO {

        let payload = ClientInsertDTO(
            owner_id: ownerId,
            first_name: firstName,
            last_name: lastName,
            phone: phone,
            comment: comment
        )

        let created: ClientDTO = try await client
            .from("clients")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value

        return created
    }

    // MARK: - Update

    func update(
        clientId: UUID,
        firstName: String,
        lastName: String?,
        phone: String,
        comment: String?
    ) async throws -> ClientDTO {

        let payload = ClientUpdateDTO(
            first_name: firstName,
            last_name: lastName,
            phone: phone,
            comment: comment
        )

        let updated: ClientDTO = try await client
            .from("clients")
            .update(payload)
            .eq("id", value: clientId.uuidString)
            .select()
            .single()
            .execute()
            .value

        return updated
    }

    // MARK: - Soft delete (RPC)

    func softDelete(clientId: UUID) async throws {
        struct Params: Encodable { let p_client_id: UUID }

        let updatedCount: Int = try await client
            .rpc("soft_delete_client", params: Params(p_client_id: clientId))
            .execute()
            .value

        if updatedCount == 0 {
            throw NSError(
                domain: "RemoteClientStore",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Client was not deleted (owner mismatch or already deleted)."]
            )
        }
    }
}
