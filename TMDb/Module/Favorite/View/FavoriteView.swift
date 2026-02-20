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
                    ScrollView {
                        LazyVStack {
                            if presenter.favorites.isEmpty {
                                EmptyView(emptyTitle: "No Favorites Found")
                            } else {
                                ForEach(presenter.favorites) { favorite in
                                    presenter.linkBuilder(for: favorite) {
                                        VStack {
                                            MovieItemView(movie: favorite.toMovieModel)
                                            
                                            if favorite != presenter.favorites.last {
                                                NativeDivider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                self.presenter.getFavorites()
            }
            .navigationTitle("Favorites")
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        FavoriteView(presenter: FavoritePresenter(favoriteUseCase: favoriteUseCase))
    }
}
