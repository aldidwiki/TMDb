import SwiftUI

struct DashboardSectionHeading: View {
    let title: String

    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(DashboardDesign.text)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview("DashboardSectionHeading") {
    DashboardSectionHeading("Now Playing")
}
#endif
