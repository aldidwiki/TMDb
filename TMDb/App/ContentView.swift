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
    @EnvironmentObject var personPresenter: PersonPresenter
    @EnvironmentObject var searchPresenter: SearchPresenter
    
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
            
            PersonView(presenter: personPresenter)
                .tabItem {
                    Label("Person", systemImage: "person.fill")
                }
            
            SearchView(presenter: searchPresenter)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FavoriteView(presenter: favoritePresenter)
                .tabItem {
                    Label("Favorite", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MoviePresenter(movieUseCase: Injection.init().provideMovieUseCase()))
        .environmentObject(FavoritePresenter(favoriteUseCase: Injection.init().provideFavoriteUseCase()))
}
