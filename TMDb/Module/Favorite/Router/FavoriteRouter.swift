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
        return MovieDetailView(
            detailUseCase: detailUseCase, movieId: movieId
        )
    }
    
    func makeTvDetailView(tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowDetailView(tvShowUseCase: tvShowUseCase, tvShowId: tvShowId)
    }
    
    func makePersonDetailView(personId: Int) -> some View {
        return PersonDetailView(
            personUseCase: Injection.init().providePersonUseCase(),
            personId: personId
        )
    }
}
