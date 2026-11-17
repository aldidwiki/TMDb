import SwiftUI

struct SearchResultsHeading: View {
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Results")
                .font(.headline)
                .foregroundStyle(DashboardDesign.text)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 12)

            Text(count == 1 ? "1 match" : "\(count) matches")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.secondaryText)
        }
    }
}

#if DEBUG
#Preview("SearchResultsHeading") {
    SearchResultsHeading(count: 3)
}
#endif
