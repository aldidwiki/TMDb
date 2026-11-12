//
//  ContentView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct ContentView: View {
    private enum BottomTab: String, CaseIterable {
        case home = "Home"
        case explore = "Explore"
        case search = "Search"
        case watchlist = "Watchlist"
        
        var symbol: String {
            switch self {
            case .home: "house"
            case .explore: "diamond.inset.filled"
            case .search: "magnifyingglass"
            case .watchlist: "heart"
            }
        }
    }
    
    @State private var selectedTab: BottomTab = .home
    @State private var activePage: BottomTab = .home
    
    var body: some View {
        TabView(selection: $activePage) {
            DashboardView(detailUseCase: Injection().provideDetailUseCase())
                .safeAreaInset(edge: .bottom, spacing: 0) { bottomNavigation }
                .toolbar(.hidden, for: .tabBar)
                .tag(BottomTab.home)

            SearchView(searchUseCase: Injection().provideSearchUseCase()) {
                bottomNavigation
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(BottomTab.search)
        }
    }
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            ForEach(BottomTab.allCases, id: \.self) { tab in
                let isSelected = tab == selectedTab
                
                Button {
                    selectedTab = tab
                    if tab == .home || tab == .search {
                        activePage = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .accessibilityHidden(true)
                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(isSelected ? DashboardDesign.accent : DashboardDesign.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(height: 60)
        .background {
            DashboardDesign.surface.ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            DashboardDesign.border.frame(height: 1)
        }
    }
}

#Preview {
    ContentView()
}
