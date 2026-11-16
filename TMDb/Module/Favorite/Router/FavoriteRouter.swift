//
//  FavoriteRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

class FavoriteRouter {
    @ViewBuilder
    func destination(for id: FavoriteModel.ID) -> some View {
        switch id.mediaType {
        case .movie:
            makeDetailView(movieId: id.mediaID)
                .toolbar(.visible, for: .navigationBar)
        case .tv:
            makeTvDetailView(tvShowId: id.mediaID)
                .toolbar(.visible, for: .navigationBar)
        case .person:
            makePersonDetailView(personId: id.mediaID)
        }
    }

    func makeDetailView(movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            detailUseCase: detailUseCase,
            favoriteUseCase: favoriteUseCase,
            movieId: movieId
        )
    }
    
    func makeTvDetailView(tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            tvShowUseCase: tvShowUseCase,
            favoriteUseCase: favoriteUseCase,
            tvShowId: tvShowId
        )
    }
    
    func makePersonDetailView(personId: Int) -> some View {
        return PersonDetailView(
            personUseCase: Injection.init().providePersonUseCase(),
            personId: personId
        )
    }
}
