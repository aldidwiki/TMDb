import SwiftUI

struct DashboardTrendingCarousel: View {
    let movies: [MovieModel]
    let metadata: (MovieModel) -> String
    let trailerID: Int?
    let watchTrailer: (MovieModel) -> Void

    @Environment(\.layoutDirection) private var layoutDirection
    @State private var carouselProgress: CGFloat = 0
    @State private var selectedPage: Int?

    var body: some View {
        VStack(spacing: 0) {
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
                                    DashboardFeaturedCard(movie: movies[index], metadata: metadata(movies[index]))
                                }
                                .buttonStyle(.plain)

                                DashboardTrailerButton(isLoading: trailerID == movies[index].id) { watchTrailer(movies[index]) }
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
            DashboardCarouselIndicator(count: movies.count, progress: carouselProgress, selectedPage: $selectedPage)
        }
    }
}

#if DEBUG
#Preview("DashboardTrendingCarousel") {
    NavigationStack {
        DashboardTrendingCarousel(movies: PreviewFixtures.movies, metadata: { String($0.releaseDate.prefix(4)) }, trailerID: nil, watchTrailer: { _ in })
    }
}
#endif
