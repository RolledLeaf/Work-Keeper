import Foundation
import Supabase

final class RemoteStreetStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch
    
    func fetchStreetChanges(ownerId: UUID, since: Date) async throws -> [StreetDTO] {
        // Use RPC for incremental sync (views can't use RLS in our setup).
        // The function enforces owner_id = auth.uid() server-side.
        struct Params: Encodable { let p_since: String }

        let rows: [StreetDTO] = try await client
            .rpc("get_street_changes", params: Params(p_since: since.iso8601String))
            .execute()
            .value

        // Extra safety: keep only expected owner (should already be enforced by RPC)
        return rows.filter { $0.owner_id == ownerId }
    }

    func fetchAll(ownerId: UUID) async throws -> [StreetDTO] {
        // RLS уже фильтрует по owner_id и deleted_at is null (через policy),
        // но ownerId всё равно полезен как "контракт" на уровне приложения.
        let result: [StreetDTO] = try await client
            .from("streets")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        // Дополнительная страховка (не обязательно, но полезно при отладке)
        return result.filter { $0.owner_id == ownerId }
    }
    
    func fetchAll(ownerId: UUID, includeDeleted: Bool = false) async throws -> [StreetDTO] {
        // Keep this as a filter-capable builder until after conditional filters are applied.
        var q = client
            .from("streets")
            .select()

        if !includeDeleted {
            // PostgREST null check: deleted_at IS NULL
            q = q.filter("deleted_at", operator: "is", value: "null")
        }

        // Apply ordering after filters (do not reassign: order returns a TransformBuilder)
        let result: [StreetDTO] = try await q
            .order("name", ascending: true)
            .execute()
            .value

        // Optional extra safety (RLS should already limit to the current user)
        return result.filter { $0.owner_id == ownerId }
    }
    
    // MARK: - Fetch by name (for Initial Upload de-duplication)

    func fetchByName(ownerId: UUID, name: String) async throws -> StreetDTO? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let result: [StreetDTO] = try await client
            .from("streets")
            .select()
            .eq("owner_id", value: ownerId.uuidString)
            .eq("name", value: trimmed)
            .limit(1)
            .execute()
            .value

        return result.first
    }

    // MARK: - Create

    func create(name: String, ownerId: UUID) async throws -> StreetDTO {
        let payload = StreetInsertDTO(owner_id: ownerId, name: name)

        // Возвращаем созданную строку (удобно для UI и локального кэша)
        let created: StreetDTO = try await client
            .from("streets")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value

        return created
    }

    // MARK: - Soft delete

    func softDelete(streetId: UUID, ownerId: UUID) async throws {
        // RPC returns how many rows were actually soft-deleted.
        // If it returns 0, it usually means: wrong id, owner_id mismatch, or already deleted.
        struct Params: Encodable { let p_street_id: UUID }

        let updatedCount: Int = try await client
            .rpc("soft_delete_street", params: Params(p_street_id: streetId))
            .execute()
            .value

        if updatedCount == 0 {
            throw NSError(
                domain: "RemoteStreetStore",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Soft delete did not update any rows. Check that owner_id matches auth.uid() and that the row isn't already deleted."]
            )
        }
    }
}
