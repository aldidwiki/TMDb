import SwiftUI

struct DashboardFeaturedCard: View {
    let movie: MovieModel
    let metadata: String

    var body: some View {
        let rating = movie.rating.formatted(.number.precision(.fractionLength(1)))

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .accessibilityHidden(true)
                Text(rating)
                    .font(.system(size: 11, weight: .bold))
            }
            .frame(minWidth: 52, minHeight: 24)
            .background(DashboardDesign.mediaFooter, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rating \(rating) out of 10")

            Spacer(minLength: 12)

            Text(movie.title)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
            if !metadata.isEmpty {
                Text(metadata)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .padding(.top, 2)
            }

            Color.clear
                .frame(width: 170, height: 42)
                .padding(.top, 13)
        }
        .foregroundStyle(DashboardDesign.surface)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(alignment: .bottom) {
            DashboardDesign.mediaFooterGradient.frame(height: 120)
        }
        .background {
            RemoteArtwork(path: movie.backdropPath, baseURL: API.backdropBaseUrl, placeholder: DashboardDesign.color(0x292667))
        }
        .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }
}

#if DEBUG
#Preview("DashboardFeaturedCard") {
    DashboardFeaturedCard(movie: PreviewFixtures.movie, metadata: "2025 · Science Fiction")
        .frame(width: 300, height: 250)
}
#endif
