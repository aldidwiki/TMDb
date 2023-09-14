//
//  TvShowEpisodeView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI

struct TvShowEpisodeView: View {
    @ObservedObject var presenter: TvShowSeasonDetailPresenter
    var tvShowId: Int
    var seasonNumber: Int
    var seasonName: String
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                List(presenter.tvShowEpisodes) { episode in
                    TvShowEpisodeItemView(episodeModel: episode)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            presenter.getTvShowSeasonDetail(tvShowId: tvShowId, seasonNumber: seasonNumber)
        }
        .navigationTitle(seasonName)
    }
}

struct TvShowEpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        
        TvShowEpisodeView(
            presenter: TvShowSeasonDetailPresenter(tvShowUseCase: tvShowUseCase),
            tvShowId: 973190,
            seasonNumber: 4,
            seasonName: "Season 4"
        )
    }
}
