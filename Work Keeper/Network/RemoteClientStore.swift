import Foundation
import Supabase

final class RemoteClientStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

    func fetchChanges(ownerId: UUID, since: Date) async throws -> [ClientDTO] {
        // Use RPC for incremental sync (views can't use RLS in our setup).
        // The function enforces owner_id = auth.uid() server-side.
        struct Params: Encodable { let p_since: String }

        let rows: [ClientDTO] = try await client
            .rpc("get_client_changes", params: Params(p_since: since.iso8601String))
            .execute()
            .value

        // Extra safety: keep only expected owner (should already be enforced by RPC)
        return rows.filter { $0.owner_id == ownerId }
    }
    
    
    func fetchAll(ownerId: UUID, includeDeleted: Bool = false) async throws -> [ClientDTO] {
        // Keep this as a filter-capable builder until after conditional filters are applied.
        var q = client
            .from("clients")
            .select()
            .eq("owner_id", value: ownerId.uuidString)

        if !includeDeleted {
          q = q.filter("deleted_at", operator: "is", value: "null")
        }

        let result: [ClientDTO] = try await q
          .order("first_name", ascending: true)
          .execute()
          .value

        return result
    }

    func fetchByPhone(ownerId: UUID, phone: String) async throws -> ClientDTO? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // RLS should scope by owner, but we filter by owner_id too for safety.
        let rows: [ClientDTO] = try await client
            .from("clients")
            .select()
            .eq("owner_id", value: ownerId.uuidString)
            .eq("phone", value: trimmed)
            .limit(1)
            .execute()
            .value

        return rows.first
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
