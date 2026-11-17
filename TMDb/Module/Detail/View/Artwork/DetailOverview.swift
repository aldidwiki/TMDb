import SwiftUI

struct DetailOverview: View {
    let posterPath: String
    let overview: String
    let rating: Double
    let voteCount: Int?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            DetailArtwork(path: posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 96, height: 144)
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                if rating > 0 || (voteCount ?? 0) > 0 {
                    ratingBadge
                }

                Text("Overview")
                    .font(.subheadline.bold())
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                let summary = overview.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(summary.isEmpty || summary == "-" ? "Overview unavailable" : summary)
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var ratingBadge: some View {
        VStack(alignment: .leading, spacing: 4) {
            if rating > 0 {
                let score = rating.formatted(.number.precision(.fractionLength(1)))
                Label(score, systemImage: "star.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DashboardDesign.surface)
                    .padding(.horizontal, 8)
                    .frame(minHeight: 24)
                    .background(DashboardDesign.text, in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityLabel("Rating \(score) out of 10")
            }

            if let count = voteCount, count > 0 {
                Text(count == 1 ? "1 vote" : "\(count.formatted(.number.notation(.compactName))) votes")
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
    }
}

#if DEBUG
#Preview("DetailOverview") {
    DetailOverview(posterPath: "", overview: PreviewFixtures.movie.overview, rating: 8.4, voteCount: 120)
}
#endif
