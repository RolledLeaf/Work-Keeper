

import SwiftUI

@main
struct Work_KeeperApp: App {
    let persistence = CoreDataStack.shared
    var body: some Scene {
        WindowGroup {
            TabBar()
                .environment(\.managedObjectContext, persistence.context)
        }
    }
}
