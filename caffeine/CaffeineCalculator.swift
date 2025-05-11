import SwiftUI

struct DrinkType: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let mgPer100ml: Double?
    let mgPerServing: Double?
    let isPerServing: Bool
}

let predefinedDrinks: [DrinkType] = [
    .init(name: "Latte", mgPer100ml: 40, mgPerServing: nil, isPerServing: false),
    .init(name: "Espresso", mgPer100ml: nil, mgPerServing: 63, isPerServing: true),
    .init(name: "Black Coffee", mgPer100ml: 60, mgPerServing: nil, isPerServing: false),
    .init(name: "Energy Drink", mgPer100ml: 32, mgPerServing: nil, isPerServing: false),
    .init(name: "Cola", mgPer100ml: 10, mgPerServing: nil, isPerServing: false),
    .init(name: "Caffeine Pill", mgPer100ml: nil, mgPerServing: 200, isPerServing: true)
]

struct CaffeineCalculator: View {
    @Binding var inputMg: String
    @State private var isExpanded = false
    @State private var selectedDrink: DrinkType = predefinedDrinks[0]
    @State private var volume: String = ""
    @State private var servings: String = ""
    @State private var resultMg: Int?

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 12) {

                HStack {
                    Picker("Drink Type", selection: $selectedDrink) {
                        ForEach(predefinedDrinks) { drink in
                            Text(drink.name).tag(drink)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    if selectedDrink.isPerServing, let perServing = selectedDrink.mgPerServing {
                        Text("\(Int(perServing)) mg / serving")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else if let per100ml = selectedDrink.mgPer100ml {
                        Text("\(Int(per100ml)) mg / 100ml")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }

                VStack(spacing: 10) {
                    HStack {
                        if selectedDrink.isPerServing {
                            TextField("Servings", text: $servings)
                                .font(.title3)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)

                            Text("serving(s)")
                                .font(.title3)
                                .foregroundColor(.primary)
                        } else {
                            TextField("Volume", text: $volume)
                                .font(.title3)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)

                            Text("ml")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                HStack {
                    Button("Calculate") {
                        calculate()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    if let result = resultMg {
                        Text("Result: \(result) mg")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.top, 4)
        } label: {
            Label("Calculator", systemImage: "pills")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.vertical, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func calculate() {
        if selectedDrink.isPerServing {
            guard let servingsCount = Double(servings),
                  let mgPerServing = selectedDrink.mgPerServing
            else {
                resultMg = nil
                return
            }

            let total = Int(servingsCount * mgPerServing)
            resultMg = total
            inputMg = "\(total)"
        } else {
            guard let vol = Double(volume),
                  let mgPer100 = selectedDrink.mgPer100ml
            else {
                resultMg = nil
                return
            }

            let total = Int((vol / 100.0) * mgPer100)
            resultMg = total
            inputMg = "\(total)"
        }
    }
}
