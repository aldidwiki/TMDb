import SwiftUI

struct DetailSeeAllLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("See All")
            Image(systemName: "arrow.right")
                .accessibilityHidden(true)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(DashboardDesign.accent)
    }
}

#if DEBUG
#Preview("DetailSeeAllLabel") {
    DetailSeeAllLabel()
}
#endif
