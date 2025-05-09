import SwiftUI

struct ContentView: View {
    @State private var selection = 1
    
    var body: some View {
        TabView(selection: $selection) {
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(0)

            EntryListView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
