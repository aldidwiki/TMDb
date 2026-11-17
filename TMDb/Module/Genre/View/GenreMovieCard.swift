import SwiftUI
import SDWebImageSwiftUI

struct GenreMovieCard: View {
    let movie: MovieModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if !movie.posterPath.isEmpty, let url = URL(string: API.imageBaseUrl + movie.posterPath) {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 86, height: 134)
                        .clipped()
                        .background(DashboardDesign.color(0x292667))
                } else {
                    DashboardDesign.color(0x292667)
                        .frame(width: 86, height: 134)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(1)
                Text(String(movie.releaseDate.prefix(4)))
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .padding(.top, 4)
                Text("★ \(movie.rating.formatted(.number.precision(.fractionLength(1))))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(DashboardDesign.color(0xF59E0B))
                    .padding(.top, 4)
                Text(movie.overview.isEmpty ? "Overview unavailable" : movie.overview)
                    .font(.system(size: 11))
                    .foregroundStyle(DashboardDesign.secondaryText)
                    .lineLimit(2)
                    .padding(.top, 4)

                NavigationLink(value: movie.id) {
                    Text("See Details")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 30)
                        .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(DashboardDesign.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}

#if DEBUG
#Preview("GenreMovieCard") {
    NavigationStack { GenreMovieCard(movie: PreviewFixtures.movie) }
}
#endif
