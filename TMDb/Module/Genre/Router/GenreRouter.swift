import SwiftUI

struct GenreRoute: Hashable {
    let id: Int
    let name: String
}

final class GenreRouter {
    func goToMovieDetailView(for movieID: Int) -> some View {
        let injection = Injection()
        return MovieDetailView(
            detailUseCase: injection.provideDetailUseCase(),
            favoriteUseCase: injection.provideFavoriteUseCase(),
            movieId: movieID
        )
    }
}
