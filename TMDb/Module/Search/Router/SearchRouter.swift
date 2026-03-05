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
        return MovieDetailView(
            detailUseCase: detailUseCase, movieId: movieId
        )
    }
    
    func goToTvDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowDetailView(
            tvShowUseCase: tvShowUseCase, tvShowId: tvId
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
