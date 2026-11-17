import SwiftUI

struct PersonBiography: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Biography")
            if let biography = text.nonPlaceholderText {
                ExpandableTextView(textData: biography, maxTextLine: 7)
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .lineSpacing(3)
            } else {
                Text("Biography unavailable")
                    .font(.subheadline)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
    }


    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.bold())
            .foregroundStyle(DashboardDesign.text)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
#Preview("PersonBiography") {
    PersonBiography(text: PreviewFixtures.person.biography)
}
#endif
