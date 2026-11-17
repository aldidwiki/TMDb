import SwiftUI

struct SearchHeading: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Search")
                .font(.title3.bold())
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)
            Text("Movies, shows, people")
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }
}

#if DEBUG
#Preview("SearchHeading") {
    SearchHeading()
}
#endif
