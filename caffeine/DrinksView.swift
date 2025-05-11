import SwiftUI
import Combine

// MARK: - Model
struct Drink: Identifiable, Decodable, Hashable {
    let name: String
    let brief: String
    let description: String?
    let type_of_caffeine: String
    let caffeine_mg_per_100ml: Int

    // Use name as a stable identifier (API does not provide one)
    var id: String { name }
}

// MARK: - View‑Model
@MainActor
final class DrinksViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var drinks: [Drink] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private var searchCancellable: AnyCancellable?
    private var fetchTask: Task<Void, Never>?

    init() {
        // Debounce the query so we are not spamming the API
        searchCancellable = $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }

        // Initial load of 25 popular drinks
        performSearch()
    }

    func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString: String
        if trimmed.isEmpty {
            urlString = "https://caffeine.eryk-janiczek.workers.dev/drinks"
        } else {
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
            urlString = "https://caffeine.eryk-janiczek.workers.dev/drinks?search=\(encoded)"
        }
        guard let url = URL(string: urlString) else { return }

        fetch(from: url)
    }

    private func fetch(from url: URL) {
        // Cancel any in‑flight request to avoid race conditions
        fetchTask?.cancel()
        fetchTask = Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode([Drink].self, from: data)
                drinks = decoded
                errorMessage = nil
            } catch {
                drinks = []
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - View
struct DrinksView: View {
    @StateObject private var vm = DrinksViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Loading indicator at the top
                if vm.isLoading && vm.drinks.isEmpty {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                }

                // Drink rows
                ForEach(vm.drinks) { drink in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(drink.name)
                                .font(.headline)
                            Spacer()
                            Text("\(drink.caffeine_mg_per_100ml)mg/100ml")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Text(drink.brief)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Type badge
                        Text(drink.type_of_caffeine)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(badgeBackground(for: drink))
                            .foregroundColor(badgeForeground(for: drink))
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Drinks")
            .searchable(text: $vm.query, prompt: "Search drinks…")
            .overlay {
                if let message = vm.errorMessage {
                    ContentUnavailableView(message, systemImage: "wifi.exclamation")
                } else if !vm.isLoading && vm.drinks.isEmpty {
                    ContentUnavailableView("No results", systemImage: "questionmark")
                }
            }
        }
    }

    // MARK: - Helpers
    private func badgeBackground(for drink: Drink) -> Color {
        drink.type_of_caffeine.localizedCaseInsensitiveContains("Synthetic") ? Color.red.opacity(0.2) : Color.gray.opacity(0.2)
    }

    private func badgeForeground(for drink: Drink) -> Color {
        drink.type_of_caffeine.localizedCaseInsensitiveContains("Synthetic") ? .red : .primary
    }
}

// MARK: - Preview
#Preview {
    DrinksView()
}
