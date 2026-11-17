import SwiftUI

struct BackdropPlaceholder: View {
    var body: some View {
        DashboardDesign.surfaceDim
            .overlay {
                ProgressView("Loading")
                    .font(.caption2)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .tint(DashboardDesign.accent)
            }
    }
}

#if DEBUG
#Preview("BackdropPlaceholder") {
    BackdropPlaceholder()
        .frame(width: 128, height: 100)
}
#endif
