//
//  TvShowSeasonDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import Combine
import Foundation
import Observation

@MainActor
@Observable
final class TvShowSeasonDetailPresenter {
    enum State {
        case idle
        case loading
        case loaded([TvShowSeasonDetailModel])
        case failed
    }

    private let tvShowUseCase: TvShowUseCase
    private let tvShowId: Int
    private var states: [Int: State] = [:]
    private var requests: [Int: AnyCancellable] = [:]

    init(tvShowUseCase: TvShowUseCase, tvShowId: Int) {
        self.tvShowUseCase = tvShowUseCase
        self.tvShowId = tvShowId
    }

    func state(for seasonNumber: Int) -> State {
        states[seasonNumber] ?? .idle
    }

    func load(seasonNumber: Int) {
        switch state(for: seasonNumber) {
        case .idle, .failed:
            break
        case .loading, .loaded:
            return
        }

        states[seasonNumber] = .loading
        requests[seasonNumber] = tvShowUseCase.getTvShowSeasonDetail(tvShowId: tvShowId, seasonNumber: seasonNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    states[seasonNumber] = .failed
                } else if case .loading = state(for: seasonNumber) {
                    states[seasonNumber] = .loaded([])
                }
                requests[seasonNumber] = nil
            } receiveValue: { [weak self] episodes in
                var seen: Set<Int> = []
                let uniqueEpisodes = episodes.filter { seen.insert($0.episodeNumber).inserted }
                self?.states[seasonNumber] = .loaded(uniqueEpisodes.sorted { $0.episodeNumber < $1.episodeNumber })
            }
    }
}
