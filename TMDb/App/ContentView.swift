//
//  ContentView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var moviePresenter: MoviePresenter
    @EnvironmentObject var favoritePresenter: FavoritePresenter
    @EnvironmentObject var tvShowPresenter: TvShowPresenter
    
    var body: some View {
        TabView {
            MovieView(presenter: self.moviePresenter)
                .tabItem {
                    Label("Movie", systemImage: "film")
                }
            
            TvShowView(presenter: tvShowPresenter)
                .tabItem {
                    Label("Tv Show", systemImage: "tv")
                }
            
            FavoriteView(presenter: favoritePresenter)
                .tabItem {
                    Label("Favorite", systemImage: "heart")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let movieUseCase = Injection.init().provideMovieUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        ContentView()
            .environmentObject(MoviePresenter(movieUseCase: movieUseCase))
            .environmentObject(FavoritePresenter(favoriteUseCase: favoriteUseCase))
    }
}
