import SwiftUI

struct PersonKnownForCard: View {
    let credit: CreditModel

    var body: some View {
        let isMovie = credit.mediaType == Constants.movieResponseType
        let media = isMovie ? "Movie" : "TV"
        let role = credit.characterName.nonPlaceholderText

        return VStack(alignment: .leading, spacing: 4) {
            PersonArtwork(
                path: credit.profilePath,
                baseURL: API.imageBaseUrl,
                fallback: DashboardDesign.color(isMovie ? 0x493255 : 0x1C5060),
                width: 140,
                height: 210,
                radius: DashboardDesign.controlRadius
            )
            .accessibilityHidden(true)

            Text(credit.name)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(1)

            Text(role.map { "\($0) · \(media)" } ?? media)
                .font(.caption)
                .foregroundStyle(DashboardDesign.secondaryText)
                .lineLimit(1)
        }
        .frame(width: 140, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("PersonKnownForCard") {
    PersonKnownForCard(credit: PreviewFixtures.credit)
}
#endif
