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
        let detailUseCase = Injection.init().provideDetailUseCase()
        return MovieDetailView(
            detailUseCase: detailUseCase, movieId: movieId
        )
    }
    
    func makeTvShowDetailView(for tvId: Int) -> some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        return TvShowDetailView(
            tvShowUseCase: tvShowUseCase, tvShowId: tvId
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
