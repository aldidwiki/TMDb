//
//  TvShowSeasonDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import Observation
import Combine
import SwiftUI

@Observable
class TvShowSeasonDetailPresenter {
    private var cancellable: Set<AnyCancellable> = []
    
    private let tvShowUseCase: TvShowUseCase
    
    var loadingState = false
    var errorMessage = ""
    var tvShowEpisodes: [TvShowSeasonDetailModel] = []
    
    init(tvShowUseCase: TvShowUseCase) {
        self.tvShowUseCase = tvShowUseCase
    }
    
    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) {
        loadingState = true
        tvShowUseCase.getTvShowSeasonDetail(tvShowId: tvShowId, seasonNumber: seasonNumber)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { episodes in
                self.tvShowEpisodes = episodes
            }.store(in: &cancellable)
    }
}
