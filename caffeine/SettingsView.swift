import SwiftUI

/// Helper: today-at-(h,m) -> Date
private func timeToday(hour: Int, minute: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour   = hour
    comps.minute = minute
    return Calendar.current.date(from: comps) ?? Date()
}

/// helper for sample data
private func startOfDay(offsetDays: Int) -> Date {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    return cal.date(byAdding: .day, value: -offsetDays, to: today)!
}

/// helper for sample data
private func makeRelativeDate(
    offsetDays: Int,
    hour: Int, minute: Int, second: Int
) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: startOfDay(offsetDays: offsetDays))
    comps.hour   = hour
    comps.minute = minute
    comps.second = second
    comps.calendar = Calendar.current
    return comps.date!
}

struct SettingsView: View {
    @AppStorage("bedTimeMinutes") private var bedTimeMinutes: Int = 23 * 60
    @State private var bedTime: Date = timeToday(hour: 23, minute: 0)
    
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @State private var showToast = false
    @State private var showClearAlert  = false

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
                
                Section(header: Text("Debug"),
                        footer: Text("You can load some sample data into the app to debug/showcase it or clear the app data.")) {
                    Button("Load sample data") {
                        addSampleData()
                        showToast = true
                    }
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Text("Clear All Data")
                            .foregroundColor(.red)
                    }
                }
                
                Section("About") {
                    Link(destination: URL(string: "https://github.com/AzpektDev/caffeine-tracker")!) {
                        Label("Source Code", systemImage: "doc.text.magnifyingglass")
                    }
                    LabeledContent("Version", value: "1.0")
                }
                
                
                
            }
            .navigationTitle("Settings")
            .alert("Sample data added!", isPresented: $showToast) {
                Button("OK", role: .cancel) { }
            }
            .alert("Clear all data?",
                   isPresented: $showClearAlert) {
                Button("Delete", role: .destructive) {
                    rawData = Data()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently remove every entry. YOU WILL NEED TO RESTART THE APP TO SEE THE CHANGES")
            }
        }
    }
    
    // MARK: - SAMPLE DATA LOADING
    private func addSampleData() {
        var entries = (try? JSONDecoder().decode([CaffeineEntry].self, from: rawData)) ?? []

        let template: [(Int, [(Int, Int, Int, Int)])] = [
            (6, [( 6,12,35,150), (10,49,49,200)]),
            (5, [( 8,21,17,200), (14,28,19,150), (16,19,25,200)]),
            (4, [(12,13,14,100), (15,19,18,150)]),
            (3, [( 7,23,19,100), ( 9,45,38,150), (10,46,59,200), (14,39,49,150)]),
            (2, [( 7,23,18,150), (13,33,23,150)]),
            (1, [( 8,53,51,150), (12,34,54,200), (15,12,19,150)]),
            (0, [(12,23,49,150), (16,54,12,200)]),
        ]

        for (offset, events) in template {
            for (h, m, s, mg) in events {
                let date = makeRelativeDate(offsetDays: offset, hour: h, minute: m, second: s)
                entries.append(CaffeineEntry(amount: mg, date: date))
            }
        }

        if let encoded = try? JSONEncoder().encode(entries) {
            rawData = encoded
        }
    }
}

#Preview {
    SettingsView()
}
