

import SwiftUI

@main
struct Work_KeeperApp: App {
    let persistence = CoreDataStack.shared
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.context)
        }
    }
}
