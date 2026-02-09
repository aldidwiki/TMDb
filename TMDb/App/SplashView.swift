//
//  SplashView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 23/06/23.
//

import SwiftUI

struct SplashView: View {
    @State var isActive = false
    
    var body: some View {
        ZStack {
            if isActive {
                let movieUseCase = Injection.init().provideMovieUseCase()
                let moviePresenter = MoviePresenter(movieUseCase: movieUseCase)
                
                let favoriteUseCase = Injection.init().provideFavoriteUseCase()
                let favoritePresenter = FavoritePresenter(favoriteUseCase: favoriteUseCase)
                
                let tvShowUseCase = Injection.init().provideTvShowUseCase()
                let tvShowPresenter = TvShowPresenter(tvShowUseCase: tvShowUseCase)
                
                let personUseCase = Injection.init().providePersonUseCase()
                let personPresenter = PersonPresenter(personUseCase: personUseCase)
                
                ContentView()
                    .environmentObject(moviePresenter)
                    .environmentObject(favoritePresenter)
                    .environmentObject(tvShowPresenter)
                    .environmentObject(personPresenter)
                    .transition(.scale)
            } else {
                ZStack {
                    Rectangle()
                        .background(Color("primary_color"))
                    
                    Color("primary_color")
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                .preferredColorScheme(.dark)
                .ignoresSafeArea()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
