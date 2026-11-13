import SwiftUI

final class DashboardRouter {
    func goToGenreMovieListing(for genre: GenreRoute) -> some View {
        GenreMovieListingView(genre: genre, useCase: Injection().provideGenreUseCase())
    }

    func goToMovieDetailView(for movieID: Int) -> some View {
        let injection = Injection()
        return MovieDetailView(
            detailUseCase: injection.provideDetailUseCase(),
            favoriteUseCase: injection.provideFavoriteUseCase(),
            movieId: movieID
        )
    }
}
