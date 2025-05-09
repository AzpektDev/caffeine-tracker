import Foundation
import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            Text("stats")
                .font(.title)
                .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
}
