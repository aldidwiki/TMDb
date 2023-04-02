//
//  TMDbApp.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

@main
struct TMDbApp: App {
    var body: some Scene {
        WindowGroup {
            let homeUseCase = Injection.init().provideHomeUseCase()
            let homePresenter = HomePresenter(homeUseCase: homeUseCase)
            let favoriteUseCase = Injection.init().provideFavoriteUseCase()
            let favoritePresenter = FavoritePresenter(favoriteUseCase: favoriteUseCase)
            
            ContentView()
                .environmentObject(homePresenter)
                .environmentObject(favoritePresenter)
        }
    }
}
