import Foundation
import Supabase

final class RemoteStreetStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

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
