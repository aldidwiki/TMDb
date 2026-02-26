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
                    GeometryReader { geometry in
                        ScrollView {
                            if presenter.favorites.isEmpty {
                                EmptyView(emptyTitle: "No Favorites Found")
                                    .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
                            } else {
                                LazyVStack {
                                    ForEach(presenter.favorites) { favorite in
                                        presenter.linkBuilder(for: favorite) {
                                            VStack {
                                                if favorite.mediaType == Constants.personType {
                                                    PersonItemView(personPopular: favorite.toPopularPersonModel)
                                                } else {
                                                    MovieItemView(movie: favorite.toMovieModel)
                                                }
                                                
                                                if favorite != presenter.favorites.last {
                                                    NativeDivider()
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
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
