import SwiftUI

struct DashboardNowPlayingSection: View {
    let state: DashboardPresenter.SectionState<MovieModel>
    let retry: () -> Void

    var body: some View {
        let spacing: CGFloat = 15

        return VStack(alignment: .leading, spacing: 9) {
            DashboardSectionHeading("Now Playing").modifier(DashboardContentInset())

            DashboardSectionContent(state: state, emptyTitle: "No movies now playing", retry: retry) { movies in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: spacing) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie.id) {
                                DashboardNowPlayingCard(movie: movie)
                            }
                            .buttonStyle(.plain)
                            .containerRelativeFrame(.horizontal, count: 3, spacing: spacing)
                        }
                    }
                }
                .contentMargins(.horizontal, DashboardDesign.contentInset, for: .scrollContent)
                .scrollIndicators(.hidden)
            }
        }
    }
}

#if DEBUG
#Preview("DashboardNowPlayingSection") {
    DashboardNowPlayingSection(state: .loaded(PreviewFixtures.movies), retry: {})
}
#endif
