//
//  FavoriteRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

class FavoriteRouter {
    func makeDetailView(movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            movieId: movieId
        )
    }
    
    func makeTvDetailView(tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase), tvShowId: tvShowId)
    }
}
