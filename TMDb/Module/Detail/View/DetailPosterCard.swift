import SwiftUI

struct DetailPosterCard: View {
    let title: String
    let posterPath: String
    let releaseDate: String

    var body: some View {
        let year = String(releaseDate.prefix(4))

        return VStack(alignment: .leading, spacing: 4) {
            DetailArtwork(path: posterPath, baseURL: API.imageBaseUrl)
                .frame(width: 109, height: 164)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DashboardDesign.text)
                .lineLimit(2)

            if !year.isEmpty {
                Text(year)
                    .font(.caption)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
        .frame(width: 109, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("DetailPosterCard") {
    DetailPosterCard(title: "The Last Horizon", posterPath: "", releaseDate: "2025-04-18")
}
#endif
