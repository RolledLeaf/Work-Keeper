
import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var context

    init() {
        // Цвет НЕвыбранных иконок + текста
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.custom(.inactiveColorsGray))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem {
                    Image(selectedTab == 0 ? "tasksActive" : "tasksInactive")
                        .resizable()
                        .frame(width: 33, height: 33)
                   
                }
                .tag(0)

            ClientsListView()
                .tabItem {
                    Image(selectedTab == 1 ? "clientsActive" : "clientsInactive")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .tag(1)
            
            NewTaskView()
                .tabItem {
                    Image(selectedTab == 2 ? "plus" : "plusInactive")
                        .resizable()
                        .frame(width: 33, height: 33)
                   
                }
                .tag(2)

            StatisticsView(context: context)
                .tabItem {
                    Image(selectedTab == 3 ? "statsActive" : "statsInactive")
                        .resizable()
                        .frame(width: 33, height: 33)
                   
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Image(selectedTab == 4 ? "settings" : "settingsInactive")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .tag(4)
        }
        .tint(Color.custom(.pitchBlack)) // цвет ВЫБРАННОГО таба (иконка + текст)
    }
}
