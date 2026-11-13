import SwiftUI

final class DashboardRouter {
    func goToMovieDetailView(for movieID: Int) -> some View {
        let injection = Injection()
        return MovieDetailView(
            detailUseCase: injection.provideDetailUseCase(),
            favoriteUseCase: injection.provideFavoriteUseCase(),
            movieId: movieID
        )
    }
}
