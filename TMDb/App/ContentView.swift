//
//  ContentView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var homePresenter: HomePresenter
    @EnvironmentObject var favoritePresenter: FavoritePresenter
    
    var body: some View {
        TabView {
            HomeView(presenter: self.homePresenter)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FavoriteView(presenter: favoritePresenter)
                .tabItem {
                    Label("Favorite", systemImage: "heart")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let homeUseCase = Injection.init().provideHomeUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        ContentView().environmentObject(HomePresenter(homeUseCase: homeUseCase))
            .environmentObject(FavoritePresenter(favoriteUseCase: favoriteUseCase))
    }
}
