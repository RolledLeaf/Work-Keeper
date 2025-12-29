import Foundation
import Supabase

final class RemoteTaskStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

    func fetchChanges(ownerId: UUID, since: Date) async throws -> [TaskDTO] {
        // RLS is not supported on views in our Supabase setup, so we use an RPC.
        // The function enforces owner_id = auth.uid() server-side.
        struct Params: Encodable { let p_since: String }

        let rows: [TaskDTO] = try await client
            .rpc("get_task_changes", params: Params(p_since: since.iso8601String))
            .execute()
            .value

        // Extra safety: keep only expected owner (should already be enforced by RPC)
        return rows.filter { $0.owner_id == ownerId }
    }
    
    
    /// Задачи за период (удобно для календаря / списка по датам)
    func fetch(from: Date, to: Date) async throws -> [TaskDTO] {
        try await client
            .from("tasks")
            .select()
            .gte("scheduled_at", value: iso(from))
            .lt("scheduled_at", value: iso(to))
            .order("scheduled_at", ascending: true)
            .execute()
            .value
    }
    
    func fetchAll(ownerId: UUID, includeDeleted: Bool = false) async throws -> [TaskDTO] {
        // Keep this as a filter-capable builder until after conditional filters are applied.
        var q = client
            .from("tasks")
            .select()

        if !includeDeleted {
            // PostgREST null check: deleted_at IS NULL
            q = q.filter("deleted_at", operator: "is", value: "null")
        }

        // Apply ordering after filters (do not reassign: order returns a TransformBuilder)
        let result: [TaskDTO] = try await q
            .order("scheduled_at", ascending: false)
            .execute()
            .value
        return result
    }

    /// Все задачи клиента (например на карточке клиента)
    func fetchByClient(clientId: UUID) async throws -> [TaskDTO] {
        try await client
            .from("tasks")
            .select()
            .eq("client_id", value: clientId.uuidString)
            .order("scheduled_at", ascending: false)
            .execute()
            .value
    }

    /// Fetch candidate tasks for a given owner+client+scheduled_at (exact timestamp match).
    /// We do extra matching client-side to avoid overly complex server predicates.
    func fetchCandidates(ownerId: UUID, clientId: UUID, scheduledAt: Date) async throws -> [TaskDTO] {
        let rows: [TaskDTO] = try await client
            .from("tasks")
            .select()
            .eq("owner_id", value: ownerId.uuidString)
            .eq("client_id", value: clientId.uuidString)
            .eq("scheduled_at", value: iso(scheduledAt))
            .order("updated_at", ascending: false)
            .execute()
            .value
        return rows
    }

    // MARK: - Create

    func create(_ payload: TaskInsertDTO) async throws -> TaskDTO {
        // На всякий случай валидируем согласованность is_remote / address_id до отправки
        try validateRemoteFlag(isRemote: payload.is_remote, addressId: payload.address_id)

        let created: TaskDTO = try await client
            .from("tasks")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value

        return created
    }

    // MARK: - Update

    func update(taskId: UUID, payload: TaskUpdateDTO) async throws -> TaskDTO {
        try validateRemoteFlag(isRemote: payload.is_remote, addressId: payload.address_id)

        let updated: TaskDTO = try await client
            .from("tasks")
            .update(payload)
            .eq("id", value: taskId.uuidString)
            .select()
            .single()
            .execute()
            .value

        return updated
    }

    // MARK: - Soft delete (RPC)

    func softDelete(taskId: UUID) async throws {
        struct Params: Encodable { let p_task_id: UUID }

        let updatedCount: Int = try await client
            .rpc("soft_delete_task", params: Params(p_task_id: taskId))
            .execute()
            .value

        if updatedCount == 0 {
            throw NSError(
                domain: "RemoteTaskStore",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Task was not deleted (owner mismatch or already deleted)."]
            )
        }
    }

    // MARK: - Helpers

    private func validateRemoteFlag(isRemote: Bool, addressId: UUID?) throws {
        // Логика из твоей CoreData: remote -> address nil, not remote -> address required
        if isRemote && addressId != nil {
            throw NSError(domain: "RemoteTaskStore", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Remote task must not have address_id"])
        }
        if !isRemote && addressId == nil {
            throw NSError(domain: "RemoteTaskStore", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Non-remote task must have address_id"])
        }
    }

    private func iso(_ date: Date) -> String {
        // PostgREST принимает ISO-строку для сравнения дат
        ISO8601DateFormatter().string(from: date)
    }
}
