import SwiftUI

struct ExploreRouter {
    private let detailRouter = DetailRouter()

    @ViewBuilder
    func destination(for id: ExploreItem.ID) -> some View {
        switch id.media {
        case .movie: detailRouter.makeMovieDetailView(for: id.value)
        case .tv: detailRouter.makeTvShowDetailView(for: id.value)
        case .person: detailRouter.makePersonDetailView(for: id.value)
        }
    }
}
