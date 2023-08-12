//
//  FavoriteView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var presenter: FavoritePresenter
    
    var body: some View {
        NavigationView {
            ZStack {
                if presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.favorites.isEmpty {
                        EmptyView(emptyTitle: "No Favorites Found")
                    } else {
                        List(self.presenter.favorites) { favorite in
                            presenter.linkBuilder(for: favorite) {
                                MovieItemView(movie: Mapper.mapFavoriteModelToMovieModel(input: favorite))
                            }
                        }
                    }
                }
            }.onAppear {
                self.presenter.getFavorites()
            }.navigationTitle("Favorites")
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        FavoriteView(presenter: FavoritePresenter(favoriteUseCase: favoriteUseCase))
    }
}
