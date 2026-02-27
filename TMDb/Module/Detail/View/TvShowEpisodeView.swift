//
//  TvShowEpisodeView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI

struct TvShowEpisodeView: View {
    @State private var presenter: TvShowSeasonDetailPresenter
    private let tvShowId: Int
    private let seasonNumber: Int
    private let seasonName: String
    
    init(tvShowUseCase: TvShowUseCase, tvShowId: Int, seasonNumber: Int, seasonName: String) {
        _presenter = State(initialValue: TvShowSeasonDetailPresenter(tvShowUseCase: tvShowUseCase))
        self.tvShowId = tvShowId
        self.seasonName = seasonName
        self.seasonNumber = seasonNumber
    }
    
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
            tvShowUseCase: tvShowUseCase,
            tvShowId: 973190,
            seasonNumber: 4,
            seasonName: "Season 4"
        )
    }
}
