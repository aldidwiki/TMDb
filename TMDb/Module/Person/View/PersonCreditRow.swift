import SwiftUI
import SDWebImageSwiftUI

struct PersonCreditRow: View {
    let item: PersonPresenter.CreditListItem

    var body: some View {
        let mediaLabel: String
        let fallbackColor: Color

        switch item.id {
        case .movie:
            mediaLabel = "Movie"
            fallbackColor = DashboardDesign.color(0x493255)
        case .tv:
            if item.episodeCount > 0 {
                let episodes = item.episodeCount == 1 ? "episode" : "episodes"
                mediaLabel = "TV • \(item.episodeCount.formatted()) \(episodes)"
            } else {
                mediaLabel = "TV"
            }
            fallbackColor = DashboardDesign.color(0x1C5060)
        }

        let shape = RoundedRectangle(cornerRadius: DashboardDesign.cardRadius)

        return HStack(spacing: 12) {
            fallbackColor
                .frame(width: 82, height: 114)
                .overlay {
                    if !item.posterPath.isEmpty, let url = URL(string: API.imageBaseUrl + item.posterPath) {
                        WebImage(url: url)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.releaseYear.map { "\(item.title) (\($0))" } ?? item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)

                if !item.roles.isEmpty {
                    Text(item.roles.joined(separator: " · "))
                        .font(.footnote)
                }

                Text(mediaLabel)
                    .font(.caption)
            }
            .foregroundStyle(DashboardDesign.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(DashboardDesign.surface, in: shape)
        .overlay {
            shape.strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview("PersonCreditRow") {
    PersonCreditRow(item: PreviewFixtures.creditItem)
}
#endif
