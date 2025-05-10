import SwiftUI

/// Helper: today-at-(h,m) -> Date
private func timeToday(hour: Int, minute: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour   = hour
    comps.minute = minute
    return Calendar.current.date(from: comps) ?? Date()
}

// for sample data
private func makeDate(
    _ y: Int, _ m: Int, _ d: Int,
    _ hh: Int, _ mm: Int, _ ss: Int
) -> Date {
    var comps = DateComponents()
    comps.year   = y; comps.month = m; comps.day = d
    comps.hour   = hh; comps.minute = mm; comps.second = ss
    comps.calendar = Calendar.current
    return comps.date ?? Date()
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

            let samples: [(Date, Int)] = [
                (makeDate(2025, 5, 27, 12, 23, 49), 150),
                (makeDate(2025, 5, 27, 16, 54, 12), 200),

                (makeDate(2025, 5, 26,  8, 53, 51), 150),
                (makeDate(2025, 5, 26, 12, 34, 54), 200),
                (makeDate(2025, 5, 26, 15, 12, 19), 150),

                (makeDate(2025, 5, 25,  7, 23, 18), 150),
                (makeDate(2025, 5, 25, 13, 33, 23), 150),

                (makeDate(2025, 5, 24,  7, 23, 19), 100),
                (makeDate(2025, 5, 24,  9, 45, 38), 150),
                (makeDate(2025, 5, 24, 10, 46, 59), 200),
                (makeDate(2025, 5, 24, 14, 39, 49), 150),

                (makeDate(2025, 5, 23, 12, 13, 14), 100),
                (makeDate(2025, 5, 23, 15, 19, 18), 150),

                (makeDate(2025, 5, 22,  8, 21, 17), 200),
                (makeDate(2025, 5, 22, 14, 28, 19), 150),
                (makeDate(2025, 5, 22, 16, 19, 25), 200),

                (makeDate(2025, 5, 21,  6, 12, 35), 150),
                (makeDate(2025, 5, 22, 10, 49, 49), 200)
            ]

            for (date, mg) in samples {
                entries.append(CaffeineEntry(amount: mg, date: date))
            }

            if let encoded = try? JSONEncoder().encode(entries) {
                rawData = encoded
            }
        }
}

#Preview {
    SettingsView()
}
