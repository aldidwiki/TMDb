//
//  FavoriteRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

class FavoriteRouter {
    func makeDetailView(movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: movieId)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
    
    func makeTvDetailView(tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowDetailView(presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase), tvShowId: tvShowId)
    }
}
