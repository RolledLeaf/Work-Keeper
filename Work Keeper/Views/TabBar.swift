
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
                        .frame(width: 25, height: 31)
                    Text("Задания")
                }
                .tag(0)

            ClientsListView()
                .tabItem {
                    Image(selectedTab == 1 ? "clientsActive" : "clientsInactive")
                    Text("Клиенты")
                }
                .tag(1)

            StatisticsView(context: context)
                .tabItem {
                    Image(selectedTab == 2 ? "statsActive" : "statsInactive")
                        .resizable()
                        .frame(width: 25, height: 31)
                    Text("Статистика")
                }
                .tag(2)
        }
        .tint(Color.custom(.pitchBlack)) // цвет ВЫБРАННОГО таба (иконка + текст)
    }
}
