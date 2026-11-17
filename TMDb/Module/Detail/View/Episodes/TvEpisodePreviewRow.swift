import SwiftUI
import SDWebImageSwiftUI

struct TvEpisodePreviewRow: View {
    let episode: TvShowSeasonDetailModel

    var body: some View {
        let airDate = episode.airDate.formatDateString(output: "MMM d, yyyy")

        return HStack(spacing: 12) {
            Text(episode.episodeCode)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DashboardDesign.accent)
                .padding(.horizontal, 8)
                .frame(minWidth: 44, minHeight: 40)
                .background(DashboardDesign.surfaceDim, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(episode.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DashboardDesign.text)
                if !airDate.isEmpty {
                    Text(airDate)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                .strokeBorder(DashboardDesign.border)
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("TvEpisodePreviewRow") {
    TvEpisodePreviewRow(episode: PreviewFixtures.episode)
}
#endif
