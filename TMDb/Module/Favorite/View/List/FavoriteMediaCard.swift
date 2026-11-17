import SwiftUI

struct FavoriteMediaCard: View {
    let favorite: FavoriteModel
    let remove: () -> Void

    var body: some View {
        let isMovie = favorite.id.mediaType == .movie
        let type = isMovie ? "Movie" : "TV"
        let year = String(favorite.releaseDate.prefix(4))

        return HStack(alignment: .top, spacing: 12) {
            DashboardDesign.color(isMovie ? 0x292667 : 0x175469)
                .frame(width: 86, height: 134)
                .overlay { FavoriteArtwork(path: favorite.posterPath, baseURL: API.imageBaseUrl) }
                .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top, spacing: 4) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(favorite.title)
                            .font(.headline)
                            .foregroundStyle(DashboardDesign.text)
                            .lineLimit(2)

                        Text(year.isEmpty ? type : "\(type) · \(year)")
                            .font(.caption)
                            .foregroundStyle(DashboardDesign.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    FavoriteRemoveButton(favorite: favorite, remove: remove)
                }

                if favorite.rating > 0 {
                    let rating = favorite.rating.formatted(.number.precision(.fractionLength(1)))
                    Label(rating, systemImage: "star.fill")
                        .font(.footnote.bold())
                        .foregroundStyle(DashboardDesign.rating)
                        .accessibilityLabel("Rating \(rating) out of 10")
                }

                if let overview = favorite.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                NavigationLink(value: favorite.id) {
                    Text("See Details")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .background(
                            DashboardDesign.accent,
                            in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See details for \(favorite.title)")
            }
            .frame(minHeight: 134)
        }
        .padding(10)
        .modifier(FavoriteSurface(radius: DashboardDesign.cardRadius))
    }
}

#if DEBUG
#Preview("FavoriteMediaCard") {
    NavigationStack { FavoriteMediaCard(favorite: PreviewFixtures.favorite, remove: {}) }
}
#endif
