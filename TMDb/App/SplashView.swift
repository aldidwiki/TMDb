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
                let favoriteUseCase = Injection.init().provideFavoriteUseCase()
                let favoritePresenter = FavoritePresenter(favoriteUseCase: favoriteUseCase)
                
                let searchUseCase = Injection.init().provideSearchUseCase()
                let searchPresenter = SearchPresenter(searchUseCase: searchUseCase)
                
                ContentView()
                    .environmentObject(favoritePresenter)
                    .environmentObject(searchPresenter)
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
