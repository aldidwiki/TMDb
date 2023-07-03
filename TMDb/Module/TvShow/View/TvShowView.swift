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
                        List(self.presenter.tvShows) { tvShow in
                            TvShowItemView(tvModel: tvShow)
                        }
                    }
                }
            }.onAppear {
                if self.presenter.tvShows.count == 0 {
                    self.presenter.getTvShows()
                }
            }
            .navigationTitle("Popular Tv Shows")
        }
    }
}

struct TvShowView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        TvShowView(presenter: TvShowPresenter(tvShowUseCase: tvShowUseCase))
    }
}
