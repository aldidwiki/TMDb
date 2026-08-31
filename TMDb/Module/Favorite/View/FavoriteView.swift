//
//  FavoriteView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI

struct FavoriteView: View {
    @State private var presenter: FavoritePresenter
    
    init(favoriteUseCase: FavoriteUseCase){
        _presenter = State(initialValue:FavoritePresenter(
            favoriteUseCase: favoriteUseCase
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    GeometryReader { geometry in
                        Group {
                            if presenter.isLoading {
                                ProgressView("Loading...")
                                    .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
                                    .containerRelativeFrame(.vertical)
                            } else if presenter.favorites.isEmpty {
                                EmptyView(emptyTitle: "No Favorites Found")
                                    .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
                                    .containerRelativeFrame(.vertical)
                            } else {
                                LazyVStack {
                                    // Anchor item for scroll reset
                                    Color.clear
                                        .frame(height: 0)
                                        .id("TOP")
                                    
                                    ForEach(presenter.favorites) { favorite in
                                        presenter.linkBuilder(for: favorite) {
                                            VStack {
                                                if favorite.mediaType == Constants.personType {
                                                    PersonItemView(personPopular: favorite.toPopularPersonModel)
                                                } else {
                                                    MovieItemView(movie: favorite.toMovieModel)
                                                }
                                                
                                                if favorite != presenter.favorites.last {
                                                    NativeDivider()
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .refreshable {
                    await presenter.getFavorites()
                }
                .onChange(of: presenter.favorites.map(\.id)) { _, _ in
                    withAnimation {
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }
            .task {
                await presenter.getFavorites()
            }
            .navigationTitle("Favorites")
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView(favoriteUseCase: Injection.init().provideFavoriteUseCase())
    }
}
