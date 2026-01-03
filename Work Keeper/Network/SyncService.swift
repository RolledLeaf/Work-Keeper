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
    
    private var isRunning = false
    
    // Auto cooldown
        private let autoCooldown: TimeInterval = 10 // sec
        private let lastAutoSyncKey = "sync.lastAutoSyncAt"
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.pullService = PullSyncService(context: context)
        self.uploadService = InitialUploadService(context: context)
    }
    
    private var lastAutoSyncAt: Date? {
         get { UserDefaults.standard.object(forKey: lastAutoSyncKey) as? Date }
         set { UserDefaults.standard.set(newValue, forKey: lastAutoSyncKey) }
     }
    
    /// Главный вход: сервер -> локально (Pull), затем локально -> сервер (Push).
       func syncAll(ownerId: UUID, trigger: Trigger, debug: Bool = true) async {
           guard !isRunning else {
               if debug { print("⏳ SyncService: sync already running, skip") }
               return
           }
           
           if trigger == .auto, let last = lastAutoSyncAt {
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
           phase = .syncing
           defer { isRunning = false }

           do {
               if debug { print("🔄 SyncAll started") }

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
               
               if trigger == .auto {
                   lastAutoSyncAt = doneAt
               }
               
               if debug { print("✅ SyncAll finished at \(doneAt)") }

           } catch {
               phase = .failure(error.localizedDescription)
               if debug { print("❌ SyncAll error:", error) }
           }
       }

       func resetStatus() {
           phase = .idle
       }
   }
