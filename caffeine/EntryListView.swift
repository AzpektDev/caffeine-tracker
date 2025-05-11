import SwiftUI
import Charts

struct CaffeineEntry: Identifiable, Codable, Equatable {
    let id = UUID()
    let amount: Int
    let date: Date
}

struct EntryListView: View {
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @AppStorage("bedTimeMinutes") private var bedTimeMinutes: Int = 23 * 60

    @State private var entries: [CaffeineEntry] = []
    @State private var isShowingAddEntry = false

    private let background = Color(.systemGroupedBackground)

    private var lastEntry: CaffeineEntry? {
        entries.max(by: { $0.date < $1.date })
    }

    private var lastAgoString: String? {
        guard let last = lastEntry else { return nil }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .full
        return rel.localizedString(for: last.date, relativeTo: Date())
    }

    ///  fade ~2 h after ingestion
    private var peakEndDate: Date? {
        guard let last = lastEntry else { return nil }
        return Calendar.current.date(byAdding: .hour, value: 2, to: last.date)
    }

    private var peakRemainingString: String? {
        guard let peakEnd = peakEndDate else { return nil }
        if peakEnd <= Date() { return nil }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .full
        return rel.localizedString(for: peakEnd, relativeTo: Date())
    }

    private var bedTimeToday: Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = bedTimeMinutes / 60
        comps.minute = bedTimeMinutes % 60
        return Calendar.current.date(from: comps) ?? Date()
    }

    private var peakConflictsBedTime: Bool {
        guard let peakEnd = peakEndDate else { return false }
        return peakEnd >= bedTimeToday
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if let lastAgo = lastAgoString {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last ingestion: \(lastAgo)")
                            .font(.subheadline.weight(.medium))

                        if let remaining = peakRemainingString {
                            Text("Peak effects fade \(remaining)")
                                .font(.footnote)
                                .foregroundColor(peakConflictsBedTime ? .red.opacity(0.85) : .secondary)
                        } else {
                            Text("Peak effects have faded")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        if peakConflictsBedTime {
                            Text("⚠︎ May still feel the buzz at bed‑time")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.85))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                Button(action: { isShowingAddEntry = true }) {
                    Text("Log consumption")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                List {
                    ForEach(entries.indices.reversed(), id: \ .self) { index in
                        let entry = entries[index]
                        VStack(alignment: .leading) {
                            Text("\(entry.amount) mg")
                                .font(.headline)
                                .foregroundColor(color(for: entry.amount))
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            entries.remove(at: entries.count - 1 - index)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(background)
            }
            .background(background)
            .navigationTitle("Caffeine Log")
            .navigationDestination(isPresented: $isShowingAddEntry) { AddEntryView(entries: $entries) }
            .onAppear(perform: loadData)
            .onChange(of: entries) { _ in saveData() }
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(entries) { rawData = encoded }
    }

    private func loadData() {
        if let decoded = try? JSONDecoder().decode([CaffeineEntry].self, from: rawData) { entries = decoded }
    }

    private func color(for amount: Int) -> Color {
        switch amount {
        case 0..<10:   return .gray
        case 10..<50:  return .blue
        case 50..<150: return .green
        case 150..<500:return .orange
        default:       return .red
        }
    }
}

#Preview {
    EntryListView()
}
