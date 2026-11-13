//
//  SearchRouter.swift
//  TMDb
//
//  Created by Macbook on 13/02/26.
//

import SwiftUI

class SearchRouter {
    @ViewBuilder
    func destination(for id: SearchModel.ID) -> some View {
        switch id.mediaType {
        case .movie:
            goToMovieDetailView(for: id.value)
        case .tv:
            goToTvDetailView(for: id.value)
        case .person:
            goToPersonDetailView(for: id.value)
        }
    }

    func goToMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            detailUseCase: detailUseCase,
            favoriteUseCase: favoriteUseCase,
            movieId: movieId
        )
    }
    
    func goToTvDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            tvShowUseCase: tvShowUseCase,
            favoriteUseCase: favoriteUseCase,
            tvShowId: tvId
        )
    }
    
    func goToPersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase()
        
        return PersonDetailView(
            personUseCase: personUseCase,
            personId: personId
        )
    }
}
