import SwiftUI

struct AddEntryView: View {
    @Binding var entries: [CaffeineEntry]
    @Environment(\.dismiss) var dismiss
    @State private var inputMg: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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

                CaffeineCalculator(inputMg: $inputMg)
                    .padding(.horizontal)

                Button("Add") {
                    addEntry()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Add Entry")
        .background(Color(.systemGroupedBackground))
    }

    private func addEntry() {
        guard let mg = Int(inputMg), mg > 0 else { return }
        let newEntry = CaffeineEntry(amount: mg, date: Date())
        entries.append(newEntry)
        dismiss()
    }
}
