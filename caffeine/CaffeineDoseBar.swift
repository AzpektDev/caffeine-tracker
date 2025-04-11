import SwiftUI

enum DoseLevel: String {
    case thresh, light, common, strong, heavy

    var color: Color {
        switch self {
        case .thresh: return .blue
        case .light: return .green
        case .common: return .yellow
        case .strong: return .orange
        case .heavy: return .red
        }
    }
}

struct CaffeineDoseBar: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: 2) {
                HStack(spacing: 17.5) {
                    Text("10")
                    Text("-")
                    Text("50")
                    Text("-")
                    Text("150")
                    Text("-")
                    Text("500")
                    Text("-")
                    Text("mg")
                }
                .font(.headline)
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [.blue, .green, .yellow, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    HStack(spacing: 17.5) {
                        Text("10")
                        Text("-")
                        Text("50")
                        Text("-")
                        Text("150")
                        Text("-")
                        Text("500")
                        Text("-")
                        Text("mg")
                    }
                    .font(.headline)
                )

                HStack(/*spacing: 3.5*/) {
                    Text("thresh")
                        .foregroundColor(DoseLevel.thresh.color)
                        .tracking(-1)

//                    Spacer().frame(width: 10)
                    
                    // pierdolone spacery

                    Text("light")
                        .foregroundColor(DoseLevel.light.color)

                    Spacer().frame(width: 25)

                    Text("common")
                        .foregroundColor(DoseLevel.common.color)

                    Spacer().frame(width: 30)

                    Text("strong")
                        .foregroundColor(DoseLevel.strong.color)

                    Spacer().frame(width: 40)

                    Text("heavy")
                        .foregroundColor(DoseLevel.heavy.color)
                    
                    Spacer().frame(width: 45)
                }
                .font(.caption)
            }
        }
//        .padding(.vertical)
    }
}
