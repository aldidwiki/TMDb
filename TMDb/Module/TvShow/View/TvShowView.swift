//
//  TvShowView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import SwiftUI

struct TvShowView: View {
    @ObservedObject var presenter: TvShowPresenter
    
    var body: some View {
        NavigationView {
            ZStack {
                if self.presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.tvShows.isEmpty {
                        EmptyView(emptyTitle: "No Tv Show Found")
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(self.presenter.tvShows) { tvShow in
                                    presenter.toTvShowDetailView(for: tvShow.id) {
                                        VStack {
                                            TvShowItemView(tvModel: tvShow)
                                            
                                            if tvShow != self.presenter.tvShows.last {
                                                NativeDivider()
                                            }
                                        }
                                    }
                                    .onAppear {
                                        if tvShow == self.presenter.tvShows.last {
                                            if self.presenter.tvShowQuery.isEmpty {
                                                self.presenter.getTvShows()
                                            } else {
                                                self.presenter.searchTvShows(query: self.presenter.tvShowQuery)
                                            }
                                        }
                                    }
                                }
                                
                                if self.presenter.isFetchingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                if self.presenter.tvShows.count == 0 {
                    self.presenter.getTvShows(reset: true)
                }
            }
            .navigationTitle("Popular Tv Shows")
        }
        .searchable(text: $presenter.tvShowQuery, placement: .automatic, prompt: "Search Tv Show")
    }
}

struct TvShowView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        TvShowView(presenter: TvShowPresenter(tvShowUseCase: tvShowUseCase))
    }
}
