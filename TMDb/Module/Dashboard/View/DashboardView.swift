import SwiftUI
import SDWebImageSwiftUI

struct DashboardView<BottomBar: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.openURL) private var openURL
    @State private var presenter: DashboardPresenter
    @State private var showsExplore = false
    @State private var showsTrailerError = false
    @State private var carouselProgress: CGFloat = 0
    @State private var selectedPage: Int?
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
                    insetContent(
                        Text("TMDb")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(DashboardDesign.accent)
                            .padding(.bottom, 10)
                            .accessibilityAddTraits(.isHeader)
                    )

                    trendingSection
                        .padding(.bottom)

                    insetContent(
                        VStack(alignment: .leading, spacing: 24) {
                            nowPlayingSection
                            genreSection
                        }
                    )
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

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            insetContent(sectionTitle("Trending Now"))
                .padding(.bottom, 15)

            sectionContent(presenter.trending, emptyTitle: "No trending movies", retry: presenter.loadTrending) { movies in
                trendingCarousel(movies)
                carouselIndicator(count: movies.count)
            }
        }
    }

    private func carouselIndicator(count: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                let emphasis = max(0, 1 - abs(carouselProgress - CGFloat(index)))
                Capsule()
                    .fill(DashboardDesign.indicator)
                    .overlay {
                        Capsule()
                            .fill(DashboardDesign.accent)
                            .opacity(Double(emphasis))
                    }
                    .frame(width: 6 + 12 * emphasis, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trending movies")
        .accessibilityValue("\((selectedPage ?? 0) + 1) of \(count)")
        .accessibilityAdjustableAction { direction in
            withAnimation {
                switch direction {
                case .increment:
                    selectedPage = min((selectedPage ?? 0) + 1, count - 1)
                case .decrement:
                    selectedPage = max((selectedPage ?? 0) - 1, 0)
                @unknown default:
                    break
                }
            }
        }
    }

    private func trendingCarousel(_ movies: [MovieModel]) -> some View {
        GeometryReader { geometry in
            let viewportWidth = geometry.size.width
            let inset = max(DashboardDesign.contentInset, (viewportWidth - DashboardDesign.contentWidth) / 2)
            let cardWidth = max(0, viewportWidth - inset * 2)
            let cardSpacing: CGFloat = 12
            let lastPage = CGFloat(movies.count - 1)
            let isRightToLeft = layoutDirection == .rightToLeft
            let viewport = "trendingCarouselViewport"

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(movies.indices, id: \.self) { index in
                        ZStack(alignment: .bottomLeading) {
                            NavigationLink(value: movies[index].id) {
                                featuredCard(movies[index])
                            }
                            .buttonStyle(.plain)

                            trailerButton(movies[index])
                                .padding(.leading, 16)
                                .padding(.bottom, 10)
                        }
                        .frame(width: cardWidth)
                    }
                }
                .scrollTargetLayout()
                .onGeometryChange(for: CGFloat.self) { geometry in
                    let frame = geometry.frame(in: .named(viewport))
                    let leading = isRightToLeft ? viewportWidth - frame.maxX : frame.minX
                    let progress = (inset - leading) / (cardWidth + cardSpacing)
                    return min(max(0, progress), lastPage)
                } action: { progress in
                    carouselProgress = progress
                }
            }
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $selectedPage, anchor: .center)
            .scrollIndicators(.hidden)
            .coordinateSpace(.named(viewport))
        }
        .frame(height: 250)
    }

    private func insetContent<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: DashboardDesign.contentWidth, alignment: .leading)
            .padding(.horizontal, DashboardDesign.contentInset)
            .frame(maxWidth: .infinity)
    }

    private func featuredCard(_ movie: MovieModel) -> some View {
        let rating = movie.rating.formatted(.number.precision(.fractionLength(1)))
        let metadata = presenter.metadata(for: movie)

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .accessibilityHidden(true)
                Text(rating)
                    .font(.system(size: 11, weight: .bold))
            }
            .frame(minWidth: 52, minHeight: 24)
            .background(DashboardDesign.mediaFooter, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rating \(rating) out of 10")

            Spacer(minLength: 12)

            Text(movie.title)
                .font(.system(size: 22, weight: .bold))
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
            if !metadata.isEmpty {
                Text(metadata)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .padding(.top, 2)
            }

            Color.clear
                .frame(width: 170, height: 42)
                .padding(.top, 13)
        }
        .foregroundStyle(DashboardDesign.surface)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(alignment: .bottom) {
            DashboardDesign.mediaFooterGradient.frame(height: 120)
        }
        .background {
            artwork(path: movie.backdropPath, baseURL: API.backdropBaseUrl, fallback: 0x292667)
        }
        .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }

    private func trailerButton(_ movie: MovieModel) -> some View {
        let isLoading = presenter.loadingTrailerID == movie.id

        return Button {
            presenter.loadTrailer(for: movie) { url in
                guard let url else {
                    showsTrailerError = true
                    return
                }

                openURL(url) { accepted in
                    showsTrailerError = !accepted
                }
            }
        } label: {
            HStack(spacing: 5) {
                if isLoading {
                    ProgressView()
                        .tint(DashboardDesign.surface)
                        .controlSize(.small)
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))
                }
                Text("Watch Trailer")
            }
            .font(.system(size: 13, weight: .semibold))
            .frame(width: 170, height: 42)
        }
        .buttonStyle(TrailerButtonStyle())
        .disabled(isLoading)
    }

    private var nowPlayingSection: some View {
        let spacing: CGFloat = 15

        return VStack(alignment: .leading, spacing: 9) {
            sectionTitle("Now Playing")

            sectionContent(presenter.nowPlaying, emptyTitle: "No movies now playing", retry: presenter.loadNowPlaying) { movies in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: spacing) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie.id) {
                                nowPlayingCard(movie)
                            }
                            .buttonStyle(.plain)
                            .containerRelativeFrame(.horizontal, count: 3, spacing: spacing)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func nowPlayingCard(_ movie: MovieModel) -> some View {
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
            artwork(path: movie.posterPath, baseURL: API.imageBaseUrl, fallback: 0x175469)
        }
        .clipShape(RoundedRectangle(cornerRadius: DashboardDesign.controlRadius))
    }

    private var genreSection: some View {
        let spacing: CGFloat = 6
        let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: 3)

        return VStack(alignment: .leading, spacing: 11) {
            sectionTitle("Browse by Genre")

            sectionContent(presenter.allGenres, emptyTitle: "No movie genres", retry: presenter.loadGenres) { genres in
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(genres) { genre in
                        NavigationLink(value: GenreRoute(id: genre.id, name: genre.name)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(genre.monogram)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(DashboardDesign.color(genre.accent))
                                    .frame(width: 24, height: 24)
                                    .background(DashboardDesign.color(genre.accent).opacity(0.12), in: Circle())
                                    .accessibilityHidden(true)

                                Text(genre.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(DashboardDesign.text)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 78, alignment: .topLeading)
                            .background(DashboardDesign.color(genre.background), in: RoundedRectangle(cornerRadius: 14))
                            .accessibilityElement(children: .combine)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private func sectionContent<Item, Content: View>(
        _ state: DashboardPresenter.SectionState<Item>,
        emptyTitle: String,
        retry: @escaping () -> Void,
        @ViewBuilder content: ([Item]) -> Content
    ) -> some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 78)
        case .loaded(let items) where items.isEmpty:
            Text(emptyTitle)
                .font(.footnote)
                .foregroundStyle(DashboardDesign.secondaryText)
                .frame(maxWidth: .infinity, minHeight: 78)
        case .loaded(let items):
            content(items)
        case .failed:
            VStack(spacing: 8) {
                Text("Couldn’t load this section.")
                    .foregroundStyle(DashboardDesign.secondaryText)
                Button("Retry", action: retry)
                    .tint(DashboardDesign.accent)
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, minHeight: 78)
        }
    }

    private func artwork(path: String?, baseURL: String, fallback: UInt32) -> some View {
        GeometryReader { geometry in
            if let path, !path.isEmpty, let url = URL(string: baseURL + path) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
        }
        .background(DashboardDesign.color(fallback))
        .accessibilityHidden(true)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(DashboardDesign.text)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct TrailerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(DashboardDesign.surface)
            .background(
                configuration.isPressed ? DashboardDesign.accentPressed : DashboardDesign.accent,
                in: RoundedRectangle(cornerRadius: DashboardDesign.controlRadius)
            )
    }
}

enum DashboardDesign {
    static let contentWidth: CGFloat = 560
    static let contentInset: CGFloat = 18
    static let background = color(0xF9F9FF)
    static let surface = color(0xFFFFFF)
    static let border = color(0xE2E6F4)
    static let accent = color(0x3B4CCA)
    static let accentPressed = color(0x2D3CA8)
    static let text = color(0x0F172A)
    static let secondaryText = color(0x64748B)
    static let mediaFooter = color(0x141B2B)
    static let mediaFooterGradient = LinearGradient(
        colors: [mediaFooter.opacity(0.95), mediaFooter.opacity(0)],
        startPoint: .bottom,
        endPoint: .top
    )
    static let indicator = color(0xDCE2F7)
    static let controlRadius: CGFloat = 12

    static func color(_ hex: UInt32) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension DashboardView where BottomBar == SwiftUI.EmptyView {
    init(dashboardUseCase: DashboardUseCase, detailUseCase: DetailUseCase) {
        self.init(dashboardUseCase: dashboardUseCase, detailUseCase: detailUseCase) {
            SwiftUI.EmptyView()
        }
    }
}

#Preview {
    let injection = Injection()
    DashboardView(
        dashboardUseCase: injection.provideDashboardUseCase(),
        detailUseCase: injection.provideDetailUseCase()
    )
}
