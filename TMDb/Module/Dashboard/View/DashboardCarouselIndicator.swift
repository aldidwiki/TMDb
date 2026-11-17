import SwiftUI

struct DashboardCarouselIndicator: View {
    let count: Int
    let progress: CGFloat
    @Binding var selectedPage: Int?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                let emphasis = max(0, 1 - abs(progress - CGFloat(index)))
                Capsule()
                    .fill(DashboardDesign.indicator)
                    .overlay {
                        Capsule()
                            .fill(DashboardDesign.accent)
                            .opacity(Double(emphasis))
                    }
                    .frame(width: 6 + 12 * emphasis, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trending movies")
        .accessibilityValue("\((selectedPage ?? 0) + 1) of \(count)")
        .accessibilityAdjustableAction { direction in
            withAnimation {
                switch direction {
                case .increment:
                    selectedPage = min((selectedPage ?? 0) + 1, count - 1)
                case .decrement:
                    selectedPage = max((selectedPage ?? 0) - 1, 0)
                @unknown default:
                    break
                }
            }
        }
    }
}

#if DEBUG
#Preview("DashboardCarouselIndicator") {
    DashboardCarouselIndicator(count: 3, progress: 0.35, selectedPage: .constant(0))
}
#endif
