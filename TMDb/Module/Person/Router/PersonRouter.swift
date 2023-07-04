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
        return MovieDetailView(presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
    
    func makeCreditDetailView(creditModelList: [CreditModel]) -> some View {
        return CreditDetailView(presenter: CreditDetailPresenter(navigateType: NavigateType.detailView), creditModelList: creditModelList)
    }
}
