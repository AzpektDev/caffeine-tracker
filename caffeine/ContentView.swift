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
            DrinksView()
                .tabItem {
                    Label("Drinks", systemImage: "cup.and.saucer.fill")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}
