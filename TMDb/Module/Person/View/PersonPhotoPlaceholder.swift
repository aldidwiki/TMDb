import SwiftUI

struct PersonPhotoPlaceholder: View {
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
#Preview("PersonPhotoPlaceholder") {
    PersonPhotoPlaceholder()
        .frame(width: 128, height: 100)
}
#endif
