import SwiftUI

struct AddEntryView: View {
    @Binding var entries: [CaffeineEntry]
    @Environment(\.dismiss) var dismiss
    @State private var inputMg: String = ""
    @State private var showTimePicker = false
    @State private var selectedDate = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
//                Text("Pure oral dose (mg)")
//                    .font(.caption)
//                    .padding(.horizontal)
//                    .foregroundColor(.gray)

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

        
                DisclosureGroup(isExpanded: $showTimePicker) {
                    DatePicker("Ingestion time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.top, 10)
                } label: {
                    Label("Set ingestion Time", systemImage: "clock")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 5)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                Button(action: addEntry) {
                    Text("Add entry")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.top)
        }
        .navigationTitle("Add entry")
        .background(Color(.systemGroupedBackground))
    }

    private func addEntry() {
        guard let mg = Int(inputMg), mg > 0 else { return }
        let newEntry = CaffeineEntry(amount: mg, date: selectedDate)
        entries.append(newEntry)
        dismiss()
    }
}
