
import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem {
                    Image(selectedTab == 0 ? "tasksActive" : "tasksInactive")
                        .resizable()
                        .frame(width: 25, height: 31)
                    Text("Задания")
                        .foregroundStyle(.pitchBlack)
                        
                }
                .tag(0)

            ClientsListView()
                .tabItem {
                    Image(selectedTab == 1 ? "clientsActive" : "clientsInactive")
                    Text("Клиенты")
                        .foregroundStyle(.pitchBlack)
                    if selectedTab == 1 {
                        
                    }
                }
                .tag(1)
            
            StatisticsView(context: context)
                .tabItem {
                    Image(selectedTab == 2 ? "statsActive" : "statsInactive")
                        .resizable()
                        .frame(width: 25, height: 31)
                    Text("Статистика")
                        .foregroundStyle(.pitchBlack)
                }
                .tag(2)
        }
        .accentColor(.black)
    }
}
