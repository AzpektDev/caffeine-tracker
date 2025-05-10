import SwiftUI
import Charts

// MARK: - Helpers
/// Helper type for the weekly‑totals bar chart.
private struct DailyTotal: Identifiable {
    let id = UUID()
    let date: Date
    let totalMg: Int
}

/// Visual phases for caffeine tolerance.
private enum TolerancePhase { case full, half }

/// One coloured bar on the tolerance timeline.
private struct ToleranceWindow: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let phase: TolerancePhase

    var barColor: Color {
        switch phase {
        case .full: return .accentColor
        case .half: return .accentColor.opacity(0.35)
        }
    }
}

// MARK: - Tolerance Builder

private struct ToleranceBuilder {
    /// 3 days → full tolerance; 14 days → baseline (half‑tolerance ends)
    private static let fullDays = 3
    private static let zeroDays = 14

    static func windows(from entries: [CaffeineEntry]) -> [ToleranceWindow] {
        // Sort ingestions chronologically
        let sorted = entries.sorted { $0.date < $1.date }
        var windows: [ToleranceWindow] = []
        let cal = Calendar.current

        for entry in sorted {
            // Remove or trim *existing* windows that extend past this ingestion
            windows = windows.compactMap { w in
                if w.end <= entry.date {
                    return w                     // fully before → keep as‑is
                } else if w.start >= entry.date {
                    return nil                   // starts after ingestion → drop
                } else {
                    // straddles ingestion → cut off at ingestion moment
                    return ToleranceWindow(start: w.start, end: entry.date, phase: w.phase)
                }
            }

            // Add new full + half windows for this ingestion
            guard let fullEnd = cal.date(byAdding: .day, value: fullDays, to: entry.date),
                  let zeroEnd = cal.date(byAdding: .day, value: zeroDays, to: entry.date) else { continue }

            windows.append(ToleranceWindow(start: entry.date, end: fullEnd, phase: .full))
            windows.append(ToleranceWindow(start: fullEnd,  end: zeroEnd, phase: .half))
        }

        // Merge overlapping windows of the same phase so the chart stays tidy
        return mergeOverlaps(in: windows)
    }

    // ------------------------------------------------------------------
    //  Helpers
    // ------------------------------------------------------------------

    private static func mergeOverlaps(in windows: [ToleranceWindow]) -> [ToleranceWindow] {
        var sorted = windows.sorted { $0.start < $1.start }
        var merged: [ToleranceWindow] = []

        while let current = sorted.first {
            sorted.removeFirst()
            var span = current

            var i = 0
            while i < sorted.count {
                let cand = sorted[i]
                if span.phase == cand.phase && cand.start <= span.end {
                    span = ToleranceWindow(start: span.start, end: max(span.end, cand.end), phase: span.phase)
                    sorted.remove(at: i)
                } else { i += 1 }
            }
            merged.append(span)
        }
        return merged
    }
}

struct StatsView: View {
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @State private var entries: [CaffeineEntry] = []

    private var weeklyTotals: [DailyTotal] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).map { off in
            let day = cal.date(byAdding: .day, value: -off, to: today)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            let sum = entries.filter { $0.date >= day && $0.date < next }.reduce(0) { $0 + $1.amount }
            return DailyTotal(date: day, totalMg: sum)
        }.reversed()
    }

    private var toleranceWindows: [ToleranceWindow] { ToleranceBuilder.windows(from: entries) }

    private var tickDates: [Date] {
        guard let first = toleranceWindows.first?.start, let last = toleranceWindows.last?.end, first < last else { return [] }
        let cal = Calendar.current
        var ticks: [Date] = []
        var current = cal.startOfDay(for: first)
        while current <= last {
            ticks.append(current)
            current = cal.date(byAdding: .day, value: 14, to: current)!
        }
        return ticks
    }
    
    
    private var todaysEntries: [CaffeineEntry] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        return entries.filter { $0.date >= start && $0.date < end }.sorted { $0.date > $1.date }
    }

    private func color(for mg: Int) -> Color {
        switch mg {
        case 0..<10:   return .gray
        case 10..<50:  return .blue
        case 50..<150: return .green
        case 150..<500:return .orange
        default:       return .red
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Last 7 days") {
                    if weeklyTotals.allSatisfy({ $0.totalMg == 0 }) {
                        ContentUnavailableView("No data yet", systemImage: "chart.bar.doc.horizontal")
                    } else {
                        Chart(weeklyTotals) { day in
                            BarMark(x: .value("Day", day.date, unit: .day),
                                    y: .value("Caffeine (mg)", day.totalMg))
                            .annotation(position: .top) { Text("\(day.totalMg)").font(.caption) }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisGridLine(); AxisValueLabel(format: .dateTime.weekday(.narrow))
                            }
                        }
                        .frame(height: 220)
                        .padding(.top, 5)
                    }
                }

                Section(header: Text("Tolerance"),
                        footer: Text("The timeline shows how your caffeine tolerance evolves after each intake: solid bars represent the ~3-day period of full tolerance, and lighter bars extend until tolerance returns to baseline (~14 days).")) {
                    if toleranceWindows.isEmpty {
                        ContentUnavailableView("No data yet", systemImage: "pills.circle")
                    } else {
                        TimelineView(.everyMinute) { ctx in
                            Chart {
                                ForEach(toleranceWindows) { w in
                                    BarMark(xStart: .value("Start", w.start),
                                            xEnd:   .value("End",   w.end),
                                            y:      .value("Substance", "Caffeine"))
                                    .foregroundStyle(w.barColor)
                                }
                                RuleMark(x: .value("Now", ctx.date))
                                    .foregroundStyle(.black)
                                    .lineStyle(StrokeStyle(lineWidth: 1))
                            }
                            .chartXAxis {
                                AxisMarks(values: tickDates) { _ in
                                    AxisGridLine(); AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            .chartYAxis(.hidden)
                            .frame(height: 80)
                        }
                    }
                }
                
                Section("Today's intakes") {
                    if todaysEntries.isEmpty {
                        ContentUnavailableView("No entries yet", systemImage: "cup.and.saucer")
                    } else {
                        ForEach(todaysEntries) { e in
                            HStack {
                                Text("\(e.amount) mg")
                                    .foregroundColor(color(for: e.amount))
                                Spacer()
                                Text(e.date, style: .time).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your stats")
            .onAppear(perform: load)
        }
    }

    private func load() {
        if let decoded = try? JSONDecoder().decode([CaffeineEntry].self, from: rawData) {
            entries = decoded
        }
    }
}

#Preview { StatsView() }
