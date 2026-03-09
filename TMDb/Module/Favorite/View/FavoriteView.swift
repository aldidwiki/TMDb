//
//  FavoriteView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import SwiftData

struct FavoriteView: View {
    @State private var presenter: FavoritePresenter

    init(){
        _presenter = State(initialValue: FavoritePresenter())
    }
    
    var body: some View {
        NavigationView {
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
                .onAppear {
                    presenter.getFavorites()
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}
