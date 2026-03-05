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
        let personUseCase = Injection.init().providePersonUseCase()
        return PersonDetailView(
            personUseCase: personUseCase,
            personId: personId
        )
    }
    
    func makeCreditDetailView(for credits: [CreditModel]) -> some View {
        return CreditDetailView(creditModelList: credits)
            .environment(CreditDetailPresenter(navigateType: NavigateType.personView))
    }
    
    func makeTvShowSeasonView(for tvShowSeasonList: [TvShowSeasonModel], title tvShowTitle: String, id tvShowId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        
        return TvShowSeasonView(
            tvShowUseCase: tvShowUseCase,
            tvShowId: tvShowId,
            tvShowTitle: tvShowTitle,
            tvShowSeasonList: tvShowSeasonList
        )
    }
    
    func makeTvShowSeasonDetailView(tvShowId: Int, seasonNumber: Int, seasonName: String) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowEpisodeView(
            tvShowUseCase: tvShowUseCase,
            tvShowId: tvShowId,
            seasonNumber: seasonNumber, 
            seasonName: seasonName
        )
    }
    
    func makeMovieImageGalleryView(movieId: Int) -> some View {
        return MovieImageGalleryView(
            detailUseCase: Injection.init().provideDetailUseCase(),
            contentId: movieId
        )
    }
    
    func makeTvShowImageGalleryView(tvShowId: Int) -> some View {
        return TvShowImageGalleryView(
            tvShowUseCase: Injection.init().provideTvShowUseCase(),
            tvShowId: tvShowId
        )
    }
}
