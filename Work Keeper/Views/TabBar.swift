
import SwiftUI

enum AppTab: Hashable {
    case tasks
    case newTask
    case clients
    case stats
    case settings
}


struct TabBar: View {
    
    @State private var selectedTab: AppTab = .tasks
    @State private var pendingCreatedTaskToast: String? = nil
    @Environment(\.managedObjectContext) private var context

    init() {
        // Цвет НЕвыбранных иконок + текста
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.custom(.inactiveColorsGray))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView(pendingCreatedTaskToast: $pendingCreatedTaskToast)
                .tabItem {
                    Image(selectedTab == AppTab.tasks ? "tasksActive" : "tasksInactive")
                     
                   
                }
                           .tag(AppTab.tasks)

            ClientsListView()
                .tabItem {
                    Image(selectedTab == AppTab.clients ? "clientsActive" : "clientsInactive")
                     
                }
                .tag(AppTab.clients)
            
            NewTaskView(onComplete: { description in
                pendingCreatedTaskToast = description
                selectedTab = .tasks
            })
                .tabItem {
                    Image(selectedTab == AppTab.newTask ? "plus" : "plusInactive")
                        
                   
                }
                .tag(AppTab.newTask)

            StatisticsView(context: context)
                .tabItem {
                    Image(selectedTab == AppTab.stats ? "statsActive" : "statsInactive")
                       
                   
                }
                .tag(AppTab.stats)
            SettingsView()
                .tabItem {
                    Image(selectedTab == AppTab.settings ? "settings" : "settingsInactive")
                      
                }
                .tag(AppTab.settings)
        }
        .tint(Color.custom(.pitchBlack)) // цвет ВЫБРАННОГО таба (иконка + текст)
    }
}
