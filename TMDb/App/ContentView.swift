//
//  ContentView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MovieView(movieUseCase: Injection.init().provideMovieUseCase())
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            
            TvShowView(tvShowUseCase: Injection.init().provideTvShowUseCase())
                .tabItem {
                    Label("Shows", systemImage: "tv")
                }
            
            PersonView(
                personUseCase: Injection.init().providePersonUseCase()
            )
            .tabItem {
                Label("Person", systemImage: "person.fill")
            }
            
            FavoriteView()
                .tabItem {
                    Label("Favorite", systemImage: "heart")
                }
            
            SearchView(searchUseCase: Injection.init().provideSearchUseCase())
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView()
}
