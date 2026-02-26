//
//  SearchRouter.swift
//  TMDb
//
//  Created by Macbook on 13/02/26.
//

import SwiftUI

class SearchRouter {
    func goToMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            movieId: movieId
        )
    }
    
    func goToTvDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase),
            tvShowId: tvId
        )
    }
    
    func goToPersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        
        return PersonDetailView(
            presenter: PersonPresenter(personUseCase: personUseCase, favoriteUseCase: favoriteUseCase),
            personId: personId
        )
    }
}
