//
//  HomeRouter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import Favorite

class HomeRouter {
    func makeDetailView(for movieId: Int) -> some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: movieId)
        let favoriteUseCase = FavoriteInjection.init().provideFavoriteUseCase()
        return DetailView(presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
}
