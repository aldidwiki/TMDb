import SwiftUI

struct DashboardGenreSection: View {
    let state: DashboardPresenter.SectionState<DashboardPresenter.GenreTile>
    let retry: () -> Void

    var body: some View {
        let spacing: CGFloat = 6
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3)

        return VStack(alignment: .leading, spacing: 11) {
            DashboardSectionHeading("Browse by Genre")

            DashboardSectionContent(state: state, emptyTitle: "No movie genres", retry: retry) { genres in
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(genres) { genre in
                        NavigationLink(value: GenreRoute(id: genre.id, name: genre.name)) {
                            DashboardGenreTile(genre: genre)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

#if DEBUG
#Preview("DashboardGenreSection") {
    DashboardGenreSection(state: .loaded([PreviewFixtures.genreTile]), retry: {})
}
#endif
