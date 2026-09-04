//
//  DashboardView.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var currentIndex: Int? = 0
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                topAppBar
                heroSection
                    .padding(.bottom, 20)
                
                newReleasesSection
                    .padding(.bottom, 30)
                
                popularTvShowSection
                    .padding(.bottom, 10)
                
                genreSection
            }
        }
    }
}

extension DashboardView {
    var topAppBar: some View {
        HStack {
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .padding(4)
                .background(Color("primary_color"))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 36, height: 36)
            
            Text("TMDb")
                .font(.system(size: 26, weight: .bold))
                .padding(.horizontal, 4)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 30, height: 30)
                .padding(.leading, 12)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea(edges: .top)
        )
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    var heroSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Trending Now")
                    .font(.system(size: 32, weight: .bold))
                
                Spacer()
                
                Text("Top 10 Global")
                    .font(.headline)
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { index in
                        HeroItemView()
                            .frame(width: 300,height: 450)
                            .id(index)
                    }
                }
                .padding(.horizontal, 20)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentIndex)
            
            PageIndicator(currentIndex: $currentIndex, totalItems: 10)
                .padding(20)
                .frame(maxWidth: .infinity)
        }
    }
    
    var newReleasesSection: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("New Releases")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text("Fresh Cinematic Premieres")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("cinematic_primary"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { _ in
                        NewReleaseItemView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    var popularTvShowSection: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Popular Tv Series")
                        .font(.system(size: 24, weight: .medium))
                    
                    Text("Top episodic binge-worthy series")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("cinematic_primary"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { _ in
                        PopularItemView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    var genreSection: some View {
        VStack(alignment: .leading) {
            Text("Explore by Genre")
                .font(.system(size: 24, weight: .medium))
            
            Text("Browse by cinematic category")
                .font(.system(size: 14))
                .foregroundStyle(Color.gray)
            
            LazyVGrid(columns: columns) {
                ForEach(ColorPalette.palettes, id: \.self) { palette in
                    GenreItemView(palette: palette)
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    DashboardView()
}
