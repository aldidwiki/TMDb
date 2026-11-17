import SwiftUI

struct SimilarTitleCard: View {
    let item: SimilarTitle

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            DetailArtwork(path: item.posterPath, baseURL: API.imageBaseUrl)
                .aspectRatio(2.0 / 3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .overlay(alignment: .topTrailing) {
                    if let rating = item.rating, rating > 0 {
                        let score = rating.formatted(.number.precision(.fractionLength(1)))
                        Label(score, systemImage: "star.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(DashboardDesign.surface)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(DashboardDesign.text.opacity(0.82), in: RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel("Rating \(score) out of 10")
                            .padding(12)
                    }
                }

            Text(item.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(2)

            let year = String(item.releaseDate.prefix(4))
            if !year.isEmpty {
                Text(year)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("SimilarTitleCard") {
    SimilarTitleCard(item: PreviewFixtures.similarTitle)
}
#endif
