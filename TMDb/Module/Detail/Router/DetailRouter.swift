//
//  DetailRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import SwiftUI

class DetailRouter {
    func makePersonDetailView(for personId: Int) -> some View {
        let personUseCase = Injection.init().providePersonUseCase(personId: personId)
        return PersonView(presenter: PersonPresenter(personUseCase: personUseCase))
    }
    
    func makeCreditDetailView(for credits: [CreditModel]) -> some View {
        return CreditDetailView(presenter: CreditDetailPresenter(navigateType: NavigateType.personView), creditModelList: credits)
    }
    
    func makeTvShowSeasonView(for tvShowSeasonList: [TvShowSeasonModel], title tvShowTitle: String, id tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        
        return TvShowSeasonView(
            tvShowId: tvShowId,
            tvShowTitle: tvShowTitle,
            tvShowSeasonList: tvShowSeasonList, 
            tvShowDetailPresenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase))
    }
    
    func makeTvShowSeasonDetailView(tvShowId: Int, seasonNumber: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowEpisodeView(
            presenter: TvShowSeasonDetailPresenter(tvShowUseCase: tvShowUseCase),
            tvShowId: tvShowId,
            seasonNumber: seasonNumber)
    }
}
