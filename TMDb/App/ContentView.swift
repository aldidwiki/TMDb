//
//  ContentView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var activePage: BottomTab = .home
    
    private let dashboardUseCase: DashboardUseCase
    private let detailUseCase: DetailUseCase
    private let exploreUseCase: ExploreUseCase
    private let searchUseCase: SearchUseCase
    private let favoriteUseCase: FavoriteUseCase

    init() {
        let injection = Injection()
        self.init(dashboardUseCase: injection.provideDashboardUseCase(), detailUseCase: injection.provideDetailUseCase(),
                  exploreUseCase: injection.provideExploreUseCase(), searchUseCase: injection.provideSearchUseCase(),
                  favoriteUseCase: injection.provideFavoriteUseCase())
    }

    init(dashboardUseCase: DashboardUseCase, detailUseCase: DetailUseCase, exploreUseCase: ExploreUseCase,
         searchUseCase: SearchUseCase, favoriteUseCase: FavoriteUseCase) {
        self.dashboardUseCase = dashboardUseCase
        self.detailUseCase = detailUseCase
        self.exploreUseCase = exploreUseCase
        self.searchUseCase = searchUseCase
        self.favoriteUseCase = favoriteUseCase
    }

    var body: some View {
        TabView(selection: $activePage) {
            DashboardView(
                dashboardUseCase: dashboardUseCase,
                detailUseCase: detailUseCase
            ) {
                BottomNavigation(activePage: $activePage)
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(BottomTab.home)

            ExploreView(useCase: exploreUseCase) {
                BottomNavigation(activePage: $activePage)
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(BottomTab.explore)

            SearchView(searchUseCase: searchUseCase) {
                BottomNavigation(activePage: $activePage)
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(BottomTab.search)

            FavoriteView(favoriteUseCase: favoriteUseCase) {
                BottomNavigation(activePage: $activePage)
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(BottomTab.favorites)
        }
    }
    
}

#if DEBUG
#Preview("App tabs") {
    let fixtures = PreviewFixtures.UseCases()
    ContentView(dashboardUseCase: fixtures, detailUseCase: fixtures, exploreUseCase: fixtures,
                searchUseCase: fixtures, favoriteUseCase: PreviewFixtures.favorites())
}
#endif
