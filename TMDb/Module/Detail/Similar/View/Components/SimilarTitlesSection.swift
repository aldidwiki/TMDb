import SwiftUI

struct SimilarTitlesSection: View {
    let sourceTitle: String
    let genres: String
    let media: SimilarTitlesView.Media
    let inset: CGFloat
    let presenter: SimilarTitlesPresenter

    private let router = DetailRouter()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                DetailSectionHeading(media.title)
                NavigationLink {
                    router.makeSimilarTitlesView(
                        sourceTitle: sourceTitle,
                        genres: genres,
                        media: media,
                        presenter: presenter
                    )
                } label: {
                    DetailSeeAllLabel()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See all \(media.resultsName)")
            }
            .padding(.horizontal, inset)

            if presenter.hasLoaded {
                if presenter.previewTitles.isEmpty {
                    message("No \(media.resultsName) available")
                        .padding(.horizontal, inset)
                } else {
                    carousel
                }
            } else if presenter.phase == .failed {
                VStack(alignment: .leading, spacing: 6) {
                    message("Couldn’t load \(media.resultsName)")
                    Button("Retry") { presenter.retry() }
                        .font(.footnote.weight(.semibold))
                }
                .padding(.horizontal, inset)
            } else {
                ProgressView("Loading \(media.resultsName)")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    private var carousel: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 12) {
                ForEach(presenter.previewTitles) { item in
                    NavigationLink {
                        router.makeSimilarTitleDetailView(for: item.id, media: media)
                    } label: {
                        DetailPosterCard(title: item.title, posterPath: item.posterPath, releaseDate: item.releaseDate)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, inset, for: .scrollContent)
        .scrollIndicators(.hidden)
    }

    private func message(_ title: String) -> some View {
        Text(title)
            .font(.footnote)
            .foregroundStyle(DashboardDesign.secondaryText)
    }
}

#if DEBUG
#Preview("SimilarTitlesSection") {
    let presenter = SimilarTitlesPresenter(sourceID: 1, fetchPage: { PreviewFixtures.UseCases().getSimilarMovies(movieId: 1, page: $0) })
    NavigationStack {
        SimilarTitlesSection(sourceTitle: "The Last Horizon", genres: "Science Fiction", media: .movie, inset: 20, presenter: presenter)
            .task { presenter.load() }
    }
}
#endif
