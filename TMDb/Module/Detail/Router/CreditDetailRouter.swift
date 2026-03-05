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
        return PersonDetailView(
            personUseCase: personUseCase,
            personId: personId
        )
    }
    
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
}
