import SwiftUI

struct DetailSectionHeading: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)
        }
    }
}

#if DEBUG
#Preview("DetailSectionHeading") {
    DetailSectionHeading("Top Cast")
}
#endif
