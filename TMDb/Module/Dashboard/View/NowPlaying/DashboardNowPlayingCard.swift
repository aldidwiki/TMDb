import SwiftUI

struct DashboardNowPlayingCard: View {
    let movie: MovieModel

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            Text(movie.title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(DashboardDesign.surface)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                .padding(.horizontal, 10)
        }
        .frame(height: 150)
        .background(alignment: .bottom) {
            DashboardDesign.mediaFooterGradient.frame(height: 72)
        }
        .background {
            RemoteArtwork(path: movie.posterPath, baseURL: API.imageBaseUrl, placeholder: DashboardDesign.color(0x175469))
        }
        .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }
}

#if DEBUG
#Preview("DashboardNowPlayingCard") {
    DashboardNowPlayingCard(movie: PreviewFixtures.movie)
        .frame(width: 100)
}
#endif
