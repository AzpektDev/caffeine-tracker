import SwiftUI
import Charts

// MARK: - Data models
struct CaffeineEntry: Identifiable, Codable, Equatable {
    let id = UUID()
    let amount: Int
    let date: Date
}

struct EntryListView: View {
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @State private var entries: [CaffeineEntry] = []
    @State private var isShowingAddEntry = false
    
    private let background = Color(.systemGroupedBackground)

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isShowingAddEntry = true
                }) {
                    Text("Add Consumption")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                List {
                    ForEach(entries.indices.reversed(), id: \.self) { index in
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
            .navigationTitle("Home")
            .navigationDestination(isPresented: $isShowingAddEntry) {
                AddEntryView(entries: $entries)
            }
            .onAppear(perform: loadData)
            .onChange(of: entries) { _ in
                saveData()
            }
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(entries) {
            rawData = encoded
        }
    }

    private func loadData() {
        if let decoded = try? JSONDecoder().decode([CaffeineEntry].self, from: rawData) {
            entries = decoded
        }
    }

    private func color(for amount: Int) -> Color {
        switch amount {
        case 0..<10: return .gray
        case 10..<50: return .blue
        case 50..<150: return .green
        case 150..<500: return .orange
        default: return .red
        }
    }
}
