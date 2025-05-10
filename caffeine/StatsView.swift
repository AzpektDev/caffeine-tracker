import SwiftUI
import Charts

/// helper type for the chart
private struct DailyTotal: Identifiable {
    let id = UUID()
    let date: Date
    let totalMg: Int
}

struct StatsView: View {
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @State private var entries: [CaffeineEntry] = []

    private var weeklyTotals: [DailyTotal] {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())

        return (0..<7).map { offset in
            let dayStart = cal.date(byAdding: .day, value: -offset, to: todayStart)!
            let nextDay  = cal.date(byAdding: .day, value:  1, to: dayStart)!

            let daySum = entries
                .filter { $0.date >= dayStart && $0.date < nextDay }
                .reduce(0) { $0 + $1.amount }

            return DailyTotal(date: dayStart, totalMg: daySum)
        }
        .reversed()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Last 7 days") {
                    if weeklyTotals.allSatisfy({ $0.totalMg == 0 }) {
                        ContentUnavailableView(
                            "No data yet",
                            systemImage: "chart.bar.doc.horizontal"
                        )
                    } else {
                        Chart(weeklyTotals) { day in
                            BarMark(
                                x: .value("Day", day.date, unit: .day),
                                y: .value("Caffeine (mg)", day.totalMg)
                            )
                            .annotation(position: .top) {
                                Text("\(day.totalMg)")
                                    .font(.caption)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.narrow))
                            }
                        }
                        .frame(height: 220)
                        .padding(.top, 5)
                    }
                }
            }
            .navigationTitle("Your stats")
            .onAppear(perform: loadEntries)
        }
    }

    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([CaffeineEntry].self, from: rawData) {
            entries = decoded
        }
    }
}

#Preview {
    StatsView()
}
