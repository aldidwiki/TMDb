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
        let personUseCase = Injection.init().providePersonUseCase(personId: personId)
        return PersonView(presenter: PersonPresenter(personUseCase: personUseCase))
    }
    
    func makeMovieDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: movieId)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        return DetailView(presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
}
