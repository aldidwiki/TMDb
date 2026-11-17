import SwiftUI

struct ExploreChip: View {
    let title: String
    var symbol: String? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let symbol {
                    Image(systemName: symbol)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .multilineTextAlignment(.center)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(selected ? DashboardDesign.surface : DashboardDesign.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 34)
            .background(selected ? DashboardDesign.accent : DashboardDesign.surface, in: Capsule())
            .overlay {
                Capsule().strokeBorder(selected ? Color.clear : DashboardDesign.border)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#if DEBUG
#Preview("ExploreChip") {
    ExploreChip(title: "Movies", selected: true, action: {})
}
#endif
