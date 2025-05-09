import SwiftUI

/// Helper: today-at-(h,m) -> Date
private func timeToday(hour: Int, minute: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour   = hour
    comps.minute = minute
    return Calendar.current.date(from: comps) ?? Date()
}

struct SettingsView: View {
    @AppStorage("bedTimeMinutes") private var bedTimeMinutes: Int = 23 * 60

    @State private var bedTime: Date = timeToday(hour: 23, minute: 0)

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    DatePicker(
                        "Bed time",
                        selection: $bedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .onChange(of: bedTime) { newValue in
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        bedTimeMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
                    }
                    .onAppear {
                        bedTime = timeToday(
                            hour: bedTimeMinutes / 60,
                            minute: bedTimeMinutes % 60
                        )
                    }
                }

                Section(
                    header: Text("About"),
                    footer: Text("This app was made for a school project and to learn SwiftUI.")
                ) {
                    Link(destination: URL(string: "https://github.com/AzpektDev/caffeine-tracker")!) {
                        Label("Source Code", systemImage: "doc.text.magnifyingglass")
                    }
                    LabeledContent("Version", value: "1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
