import SwiftUI

struct FullCastRow: View {
    let credit: CreditModel
    let media: FullCastView.Media

    private var subtitle: String {
        let character = credit.characterName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard media == .tv, credit.episodeCount > 0 else { return character }

        let episodes = credit.episodeCount == 1 ? "1 episode" : "\(credit.episodeCount) episodes"
        return character.isEmpty ? episodes : "\(character) • \(episodes)"
    }

    var body: some View {
        let detail = subtitle
        let shape = RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)

        HStack(spacing: 10) {
            DetailCastAvatar(credit: credit, diameter: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(credit.name)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)

                if !detail.isEmpty {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(DashboardDesign.surface, in: shape)
        .overlay {
            shape.strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview("FullCastRow") {
    FullCastRow(credit: PreviewFixtures.credit, media: .movie)
}
#endif
