import SwiftUI

struct GenreMovieList: View {
    let movies: [MovieModel]
    let hasLoaded: Bool
    let isLoading: Bool
    let isLoadingMore: Bool
    let loadError: Bool
    let loadMoreError: Bool
    let listVersion: Int
    let load: () -> Void
    let loadMore: () -> Void
    let loadMoreIfNeeded: (MovieModel) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Group {
                if isLoading {
                    ProgressView("Loading movies")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if loadError {
                    VStack(spacing: 12) {
                        Label("Couldn’t load movies", systemImage: "wifi.exclamationmark")
                            .foregroundStyle(DashboardDesign.secondaryText)
                        Button("Retry") { load() }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else if hasLoaded && movies.isEmpty {
                    ContentUnavailableView("No movies found", systemImage: "movieclapper",
                                           description: Text("Try another year or rating."))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(movies) { movie in
                            GenreMovieCard(movie: movie)
                                .onAppear { loadMoreIfNeeded(movie) }
                        }
                        if isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        } else if loadMoreError {
                            Button("Couldn’t load more movies. Retry") { loadMore() }
                                .font(.footnote)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.visible)
        .id(listVersion)
    }
}

#if DEBUG
#Preview("Genre movie list") {
    NavigationStack {
        GenreMovieList(movies: PreviewFixtures.movies, hasLoaded: true, isLoading: false, isLoadingMore: false,
                       loadError: false, loadMoreError: false, listVersion: 0, load: {}, loadMore: {}, loadMoreIfNeeded: { _ in })
    }
}
#endif
