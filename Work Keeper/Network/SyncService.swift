import Foundation
import CoreData

@MainActor
final class SyncService: ObservableObject {
    
    enum Phase: Equatable {
        case idle
        case syncing
        case success(Date)
        case failure(String)
    }
    
    enum Trigger {
           case manual
           case auto
       }

    
    @Published private(set) var phase: Phase = .idle
    
    private let context: NSManagedObjectContext
    private let pullService: PullSyncService
    private let uploadService: InitialUploadService
    private let remoteTaskStore = RemoteTaskStore()
    private let remoteAddressStore = RemoteAddressStore()
    private let remoteClientStore = RemoteClientStore()
    
    private var isRunning = false
    
    // Auto cooldown
    private let autoCooldown: TimeInterval = 10 // sec

    /// Per-owner cooldown checkpoint to avoid mixing when switching accounts.
    private func lastAutoSyncKey(ownerId: UUID) -> String {
        "sync.lastAutoSyncAt.\(ownerId.uuidString)"
    }
    
    private var phaseResetTask: Task<Void, Never>?
      
      private func schedulePhaseReset(after seconds: Double) {
          // отменяем предыдущий таймер
          phaseResetTask?.cancel()

          phaseResetTask = Task { [weak self] in
              // sleep может бросить CancellationError — нам ок, просто выходим
              try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
              guard let self else { return }

              // важный guard: если сейчас снова syncing — не сбрасываем
              if case .syncing = self.phase { return }

              self.phase = .idle
          }
      }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.pullService = PullSyncService(context: context)
        self.uploadService = InitialUploadService(context: context)
    }
    

    /// Ensures the Supabase SDK has an active session (so requests are authenticated).
    private func ensureSupabaseSessionReady(debug: Bool) async throws {
        // Supabase client auth.session is async/throwing in current SDKs.
        _ = try await SupabaseManager.shared.client.auth.session
        if debug { print("🔐 Supabase session is ready") }
    }
    
    private func loadLastAutoSyncAt(ownerId: UUID) -> Date? {
        UserDefaults.standard.object(forKey: lastAutoSyncKey(ownerId: ownerId)) as? Date
    }

    private func saveLastAutoSyncAt(_ date: Date?, ownerId: UUID) {
        UserDefaults.standard.set(date, forKey: lastAutoSyncKey(ownerId: ownerId))
    }
    
    // MARK: - Tombstones (PendingDelete)

    /// Pushes local tombstones (hard-deletes) to the server so items won't "resurrect" on the next pull.
    /// After a successful server update, the tombstone row is removed locally.
    private func pushPendingDeletes(ownerId: UUID, debug: Bool) async throws {
        // We use KVC to avoid tight coupling to generated NSManagedObject subclasses.
        let req = NSFetchRequest<NSManagedObject>(entityName: "PendingDelete")
        req.returnsObjectsAsFaults = false

        let rows = try context.fetch(req)
        if debug { print("🪦 PendingDelete to push: \(rows.count)") }
        guard !rows.isEmpty else { return }

        var didDeleteAny = false

        for row in rows {
            let objectName = (row.value(forKey: "objectName") as? String) ?? ""
            let remoteIdStr = (row.value(forKey: "remoteId") as? String) ?? ""
            let deletedAt = (row.value(forKey: "deletedAt") as? Date) ?? Date()

            guard let remoteUUID = UUID(uuidString: remoteIdStr) else {
                if debug { print("⚠️ PendingDelete skip: bad remoteId=\(remoteIdStr) objectName=\(objectName)") }
                continue
            }

            switch objectName {
            case "tasks":
                // Mark as deleted on server (soft-delete via deleted_at). This prevents resurrection.
                _ = try await remoteTaskStore.softDelete(taskId: remoteUUID, ownerId: ownerId, deletedAt: deletedAt)
                if debug { print("🗑️ Pushed tombstone -> server soft-delete Task \(remoteUUID)") }
                context.delete(row)
                didDeleteAny = true

            case "addresses":
                // Mark as deleted on server (soft-delete via deleted_at). This prevents resurrection.
                _ = try await remoteAddressStore.softDelete(addressId: remoteUUID, ownerId: ownerId, deletedAt: deletedAt)
                if debug { print("🗑️ Pushed tombstone -> server soft-delete Address \(remoteUUID)") }
                context.delete(row)
                didDeleteAny = true

            case "clients":
                // Mark as deleted on server (soft-delete via deleted_at). This prevents resurrection.
                _ = try await remoteClientStore.softDelete(clientId: remoteUUID, ownerId: ownerId, deletedAt: deletedAt)
                if debug { print("🗑️ Pushed tombstone -> server soft-delete Client \(remoteUUID)") }
                context.delete(row)
                didDeleteAny = true

            default:
                if debug { print("⚠️ PendingDelete unsupported objectName=\(objectName), skip") }
                continue
            }
        }

        if didDeleteAny {
            do {
                try context.save()
                if debug { print("🪦 PendingDelete saved after push") }
            } catch {
                print("❌ PendingDelete save error:", error)
            }
        }
    }
    
    func runManualSync(
           auth: AuthService,
           debug: Bool = false
       ) {
           guard let ownerId = auth.session?.user.id else {
               if debug { print("⚠️ ManualSync skipped: no ownerId") }
               return
           }

           Task {
               await syncAll(
                   ownerId: ownerId,
                   trigger: .manual,
                   debug: debug
               )
           }
       }
    
    /// Главный вход: сервер -> локально (Pull), затем локально -> сервер (Push).
       func syncAll(ownerId: UUID, trigger: Trigger, debug: Bool = true) async {
           guard !isRunning else {
               if debug { print("⏳ SyncService: sync already running, skip") }
               return
           }
           
           if trigger == .auto, let last = loadLastAutoSyncAt(ownerId: ownerId) {
               let elapsed = Date().timeIntervalSince(last)
               if elapsed < autoCooldown {
                   if debug {
                       let left = Int(autoCooldown - elapsed)
                       print("⏱️ SyncService: auto cooldown, skip (\(left)s left)")
                   }
                   return
               }
           }

           isRunning = true
           phaseResetTask?.cancel()
           phase = .syncing
           defer { isRunning = false }

           do {
               if debug { print("🔄 SyncAll started") }

               // Ensure the SDK session is actually attached to requests.
               try await ensureSupabaseSessionReady(debug: debug)

               // 0) Tombstones: push "hard delete" markers first so deleted items won't resurrect
               try await pushPendingDeletes(ownerId: ownerId, debug: debug)

               // 1) Pull: применяем изменения с сервера локально
               try await pullService.run(ownerId: ownerId, debug: debug)

               // 2) Push: отправляем локальные изменения (needsSync=true) на сервер
               // Важно: порядок из-за зависимостей
               try await uploadService.pushStreets(ownerId: ownerId, debug: debug)
               try await uploadService.pushClients(ownerId: ownerId, debug: debug)
               try await uploadService.pushAddresses(ownerId: ownerId, debug: debug)
               try await uploadService.pushTasks(ownerId: ownerId, debug: debug)

               let doneAt = Date()
               phase = .success(doneAt)
               schedulePhaseReset(after: 2.0)
               if trigger == .auto {
                   saveLastAutoSyncAt(doneAt, ownerId: ownerId)
               }
               
               if debug { print("✅ SyncAll finished at \(doneAt)") }

           } catch {
               phase = .failure(error.localizedDescription)
               schedulePhaseReset(after: 3.0)
               if debug { print("❌ SyncAll error:", error) }
           }
       }

       func resetStatus() {
           phase = .idle
       }
   }
