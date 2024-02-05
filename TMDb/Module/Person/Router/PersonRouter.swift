//
//  PersonRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 10/05/23.
//

import Foundation
import SwiftUI

class PersonRouter {
    func makeMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: movieId)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
    
    func makeTvShowDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase),
            tvShowId: tvId
        )
    }
    
    func makeCreditDetailView(creditModelList: [CreditModel]) -> some View {
        return CreditDetailView(presenter: CreditDetailPresenter(navigateType: NavigateType.detailView), creditModelList: creditModelList)
    }
}
