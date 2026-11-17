import SwiftUI

struct DashboardView<BottomBar: View>: View {
    @Environment(\.openURL) private var openURL
    @State private var presenter: DashboardPresenter
    @State private var showsTrailerError = false
    private let bottomBar: BottomBar
    private let router = DashboardRouter()

    init(dashboardUseCase: DashboardUseCase, detailUseCase: DetailUseCase, @ViewBuilder bottomBar: () -> BottomBar) {
        _presenter = State(initialValue: DashboardPresenter(
            dashboardUseCase: dashboardUseCase,
            detailUseCase: detailUseCase
        ))
        self.bottomBar = bottomBar()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("TMDb")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(DashboardDesign.accent)
                        .padding(.bottom, 10)
                        .accessibilityAddTraits(.isHeader)
                        .modifier(DashboardContentInset())

                    DashboardTrendingSection(
                        state: presenter.trending,
                        metadata: presenter.metadata,
                        trailerID: presenter.loadingTrailerID,
                        retry: presenter.loadTrending,
                        watchTrailer: watchTrailer
                    )
                    .padding(.bottom)

                    VStack(alignment: .leading, spacing: 24) {
                        DashboardNowPlayingSection(state: presenter.nowPlaying, retry: presenter.loadNowPlaying)
                        DashboardGenreSection(state: presenter.allGenres, retry: presenter.loadGenres)
                            .modifier(DashboardContentInset())
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .background(DashboardDesign.background.ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
            .navigationDestination(for: Int.self) { movieID in
                router.goToMovieDetailView(for: movieID)
            }
            .navigationDestination(for: GenreRoute.self) { genre in
                router.goToGenreMovieListing(for: genre)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.light)
        .task { presenter.load() }
        .alert("Trailer unavailable", isPresented: $showsTrailerError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The trailer couldn’t be opened. Please try again later.")
        }
    }

    private func watchTrailer(_ movie: MovieModel) {
        presenter.loadTrailer(for: movie) { url in
            guard let url else {
                showsTrailerError = true
                return
            }

            openURL(url) { accepted in
                showsTrailerError = !accepted
            }
        }
    }
}

extension DashboardView where BottomBar == SwiftUI.EmptyView {
    init(dashboardUseCase: DashboardUseCase, detailUseCase: DetailUseCase) {
        self.init(dashboardUseCase: dashboardUseCase, detailUseCase: detailUseCase) {
            SwiftUI.EmptyView()
        }
    }
}

#if DEBUG
#Preview("Dashboard") {
    DashboardView(dashboardUseCase: PreviewFixtures.UseCases(), detailUseCase: PreviewFixtures.UseCases())
}
#endif
