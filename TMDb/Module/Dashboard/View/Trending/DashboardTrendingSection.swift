import SwiftUI

struct DashboardTrendingSection: View {
    let state: DashboardPresenter.SectionState<MovieModel>
    let metadata: (MovieModel) -> String
    let trailerID: Int?
    let retry: () -> Void
    let watchTrailer: (MovieModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DashboardSectionHeading("Trending Now").modifier(DashboardContentInset())
                .padding(.bottom, 15)

            DashboardSectionContent(state: state, emptyTitle: "No trending movies", retry: retry) { movies in
                DashboardTrendingCarousel(movies: movies, metadata: metadata, trailerID: trailerID, watchTrailer: watchTrailer)
            }
        }
    }
}

#if DEBUG
#Preview("DashboardTrendingSection") {
    DashboardTrendingSection(state: .loaded(PreviewFixtures.movies), metadata: { String($0.releaseDate.prefix(4)) }, trailerID: nil, retry: {}, watchTrailer: { _ in })
}
#endif
