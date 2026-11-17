import SwiftUI
import SDWebImageSwiftUI

struct SearchMediaCard: View {
    let result: SearchModel

    var body: some View {
        let isMovie = result.id.mediaType == .movie
        let type = isMovie ? "Movie" : "TV"
        let year = String(result.releaseDate.prefix(4))

        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                DashboardDesign.color(isMovie ? 0x292667 : 0x175469)
                if !result.imagePath.isEmpty {
                    WebImage(url: PosterURLType.movie(path: result.imagePath).url)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 86, height: 134)
            .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(result.name)
                    .font(.headline)
                    .foregroundStyle(DashboardDesign.text)
                    .lineLimit(2)

                Text(year.isEmpty ? type : "\(type) · \(year)")
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)

                if let rating = result.voteAverage, rating > 0 {
                    Label {
                        Text(rating, format: .number.precision(.fractionLength(1)))
                    } icon: {
                        Image(systemName: "star.fill")
                            .accessibilityHidden(true)
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(DashboardDesign.rating)
                    .accessibilityLabel("Rating \(rating.formatted(.number.precision(.fractionLength(1)))) out of 10")
                }

                if !result.overview.isEmpty {
                    Text(result.overview)
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                NavigationLink(value: result.id) {
                    Text("See Details")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(DashboardDesign.surface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                        .background(DashboardDesign.accent, in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See details for \(result.name)")
            }
            .frame(minHeight: 134)
        }
        .padding(10)
        .modifier(SearchCardStyle())
    }
}

#if DEBUG
#Preview("SearchMediaCard") {
    NavigationStack { SearchMediaCard(result: PreviewFixtures.search) }
}
#endif
