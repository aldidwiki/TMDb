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
                let homeUseCase = Injection.init().provideHomeUseCase()
                let homePresenter = HomePresenter(homeUseCase: homeUseCase)
                let favoriteUseCase = Injection.init().provideFavoriteUseCase()
                let favoritePresenter = FavoritePresenter(favoriteUseCase: favoriteUseCase)
                
                ContentView()
                    .environmentObject(homePresenter)
                    .environmentObject(favoritePresenter)
                    .transition(.scale)
            } else {
                Rectangle()
                    .background(Color("primary_color"))
                
                Color("primary_color")
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
