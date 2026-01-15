import SwiftUI
import CoreData

@main
struct Work_KeeperApp: App {
    let persistence = CoreDataStack.shared

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var auth = AuthService()
    @StateObject private var syncService: SyncService
    @StateObject private var networkMonitor = NetworkMonitor()

    init() {
        _syncService = StateObject(wrappedValue: SyncService(context: CoreDataStack.shared.context))
    }

    private func purgeLocalCoreData() {
        let context = persistence.context
        context.perform {
            let entityNames = ["TaskEntity", "Client", "Address", "Street"]

            for name in entityNames {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
                deleteRequest.resultType = .resultTypeObjectIDs

                do {
                    let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                    if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                    }
                } catch {
                    print("❌ Purge failed for \(name):", error)
                }
            }

            do {
                if context.hasChanges { try context.save() }
            } catch {
                print("❌ CoreData save after purge failed:", error)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.context)
                .environmentObject(auth)
                .environmentObject(syncService)
                .environmentObject(networkMonitor)
                .onOpenURL { url in
                                    auth.handleOpenURL(url)
                                }
                .task {
                    if auth.purgeLocalDataHandler == nil {
                        auth.purgeLocalDataHandler = { purgeLocalCoreData() }
                    }

                    await auth.restoreSession()
                    guard let ownerId = auth.userId, auth.state == .authenticated else { return }
                    await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                }
                .onChange(of: scenePhase) { phase in
                    guard phase == .active else { return }
                    Task {
                        guard let ownerId = auth.userId, auth.state == .authenticated else { return }
                        await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                    }
                }
                .onChange(of: auth.session?.user.id) { _ in
                    guard let ownerId = auth.userId, auth.state == .authenticated else { return }
                    Task {
                        await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                    }
                }
                .onChange(of: networkMonitor.isOnline) { isOnline in
                    guard isOnline else { return }
                    Task {
                        guard let ownerId = auth.userId, auth.state == .authenticated else { return }
                        await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                    }
                }
        }
    }
}
