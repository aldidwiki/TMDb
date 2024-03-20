//
//  CreditDetailRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import Foundation
import SwiftUI

class CreditDetailRouter {
    func makePersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase()
        return PersonDetailView(presenter: PersonPresenter(personUseCase: personUseCase), personId: personId)
    }
    
    func makeMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            movieId: movieId
        )
    }
    
    func makeTvShowDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase),
            tvShowId: tvId
        )
    }
}
