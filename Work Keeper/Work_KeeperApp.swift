import SwiftUI

@main
struct Work_KeeperApp: App {
    let persistence = CoreDataStack.shared

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var auth = AuthService()
    @StateObject private var syncService: SyncService

    init() {
        // SyncService needs a context at init time
        _syncService = StateObject(wrappedValue: SyncService(context: CoreDataStack.shared.context))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.context)
                .environmentObject(auth)
                .environmentObject(syncService)
                .task {
                    // Cold start: wait for session restoration, then auto-sync
                    await auth.restoreSession()
                    guard let ownerId = auth.session?.user.id else { return }
                    await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                }
                .onChange(of: scenePhase) { phase in
                    guard phase == .active else { return }
                    Task {
                        guard let ownerId = auth.session?.user.id else { return }
                        await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                    }
                }
                .onChange(of: auth.session?.user.id) { _ in
                    guard let ownerId = auth.session?.user.id else { return }
                    Task {
                        await syncService.syncAll(ownerId: ownerId, trigger: .auto, debug: true)
                    }
                }
        }
    }
}
