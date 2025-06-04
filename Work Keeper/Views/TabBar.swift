import SwiftUICore
import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 0

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
                    if selectedTab == 1 {
                        
                    }
                }
                .tag(1)
        }
        .accentColor(.black)
    }
}
