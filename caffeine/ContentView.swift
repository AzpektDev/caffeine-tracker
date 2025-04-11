import SwiftUI

// MARK: - Data models

struct CaffeineEntry: Identifiable, Codable {
    let id = UUID()
    let amount: Int
    let date: Date
}

// MARK: - main view

struct ContentView: View {
    @AppStorage("caffeineData") private var rawData: Data = Data()
    @State private var entries: [CaffeineEntry] = []
    @State private var inputMg: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("☕️ Caffeine")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)

        
            Text("PURE ORAL DOSE")
                .font(.caption)
                .padding(.horizontal)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 10) {
                CaffeineDoseBar()

                HStack {
                    TextField("Pure Dose", text: $inputMg)
                        .font(.title3)
                        .keyboardType(.numberPad)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)

                    Text("mg")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 4)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

//            Text("1 mg = 1/1000 gram")
//                .font(.footnote)
//                .foregroundColor(.gray)
//                .padding(.horizontal)

            CaffeineCalculator(inputMg: $inputMg)
                .padding(.horizontal)
            
            Button("Add") {
                addEntry()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            // lista
            List(entries.reversed()) { entry in
                VStack(alignment: .leading) {
                    Text("\(entry.amount) mg")
                        .font(.headline)
                        .foregroundColor(color(for: entry.amount))
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear(perform: loadData)
    }

    // MARK: - logic

    private func addEntry() {
        guard let mg = Int(inputMg), mg > 0 else { return }
        let newEntry = CaffeineEntry(amount: mg, date: Date())
        entries.append(newEntry)
        inputMg = ""
        saveData()
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
