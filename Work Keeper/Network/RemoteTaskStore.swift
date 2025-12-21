import Foundation
import Supabase

final class RemoteTaskStore {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }

    // MARK: - Fetch

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
