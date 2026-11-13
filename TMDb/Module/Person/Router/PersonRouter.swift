//
//  PersonRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 10/05/23.
//

import Foundation
import SwiftUI

class PersonRouter {
    enum CreditRoute: Hashable {
        case movie(Int)
        case tv(Int)

        init?(credit: CreditModel) {
            switch credit.mediaType {
            case Constants.movieResponseType: self = .movie(credit.id)
            case Constants.tvShowResponseType: self = .tv(credit.id)
            default: return nil
            }
        }
    }

    @ViewBuilder
    func destination(for route: CreditRoute) -> some View {
        switch route {
        case .movie(let id): makeMovieDetailView(for: id)
        case .tv(let id): makeTvShowDetailView(for: id)
        }
    }

    func makeMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return MovieDetailView(
            detailUseCase: detailUseCase,
            favoriteUseCase: favoriteUseCase,
            movieId: movieId
        )
    }
    
    func makeTvShowDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return TvShowDetailView(
            tvShowUseCase: tvShowUseCase,
            favoriteUseCase: favoriteUseCase,
            tvShowId: tvId
        )
    }
    
    func makeCreditDetailView(creditModelList: [CreditModel]) -> some View {
        return CreditDetailView(creditModelList: creditModelList)
            .environment(CreditDetailPresenter(navigateType: NavigateType.detailView))
    }
    
    func makePersonImageView(personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase()
        return PersonImageView(
            personUseCase: personUseCase,
            personId: personId
        )
    }
}
