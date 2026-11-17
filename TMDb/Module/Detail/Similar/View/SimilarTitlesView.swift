import SwiftUI

struct SimilarTitlesView: View {
    enum Media {
        case movie
        case tv

        var title: String {
            switch self {
            case .movie: "Similar Movies"
            case .tv: "Similar Shows"
            }
        }

        var resultsName: String {
            switch self {
            case .movie: "similar movies"
            case .tv: "similar shows"
            }
        }
    }

    let sourceTitle: String
    let genres: String
    let media: Media
    let presenter: SimilarTitlesPresenter

    private let router = DetailRouter()
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 2)

    var body: some View {
        GeometryReader { geometry in
            let inset = max(20, (geometry.size.width - DashboardDesign.contentWidth) / 2)

            VStack(spacing: 0) {
                DetailToolbar(title: media.title)
                    .padding(.horizontal, inset)
                header
                    .padding(.horizontal, inset)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                results(inset: inset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(DashboardDesign.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .tint(DashboardDesign.accent)
        .task { presenter.load() }
    }

    private var header: some View {
        let contextGenres = genres.replacingOccurrences(of: ", ", with: " · ")

        return VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("More like \(sourceTitle)")
                    .font(.headline)
                    .foregroundStyle(DashboardDesign.text)
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 0)

                if presenter.hasLoaded {
                    let count = presenter.totalResults ?? presenter.loadedCount
                    Text(count == 1 ? "1 title" : "\(count.formatted()) titles")
                        .font(.caption)
                        .foregroundStyle(DashboardDesign.secondaryText)
                }
            }

            if !contextGenres.isEmpty {
                Text(contextGenres)
                    .font(.footnote)
                    .foregroundStyle(DashboardDesign.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func results(inset: CGFloat) -> some View {
        if !presenter.hasLoaded {
            if presenter.phase == .failed {
                ContentUnavailableView {
                    Label("Couldn’t load \(media.resultsName)", systemImage: "wifi.exclamationmark")
                } actions: {
                    Button("Retry") { presenter.retry() }
                }
            } else {
                ProgressView("Loading \(media.resultsName)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else if presenter.loadedCount == 0 && !presenter.hasMore {
            ContentUnavailableView("No \(media.resultsName) available", systemImage: "rectangle.on.rectangle")
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 18) {
                        ForEach(presenter.titles) { item in
                            NavigationLink {
                                router.makeSimilarTitleDetailView(for: item.id, media: media)
                            } label: {
                                SimilarTitleCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    paginationFooter
                }
                .padding(.horizontal, inset)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.visible)
        }
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if presenter.hasMore {
            if presenter.phase == .failed {
                VStack(spacing: 6) {
                    Text("Couldn’t load more titles")
                        .font(.footnote)
                        .foregroundStyle(DashboardDesign.secondaryText)
                    Button("Retry") { presenter.retry() }
                        .font(.footnote.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Loading more titles")
                    .frame(maxWidth: .infinity)
                    .task(id: presenter.nextPage) { presenter.loadMore() }
            }
        }
    }
}

#if DEBUG
#Preview("SimilarTitlesView") {
    NavigationStack {
        SimilarTitlesView(sourceTitle: "The Last Horizon", genres: "Science Fiction", media: .movie,
                          presenter: SimilarTitlesPresenter(sourceID: 1, fetchPage: { PreviewFixtures.UseCases().getSimilarMovies(movieId: 1, page: $0) }))
    }
}
#endif
