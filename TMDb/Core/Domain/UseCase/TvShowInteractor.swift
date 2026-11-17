//
//  TvShowInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation
import Combine

protocol TvShowUseCase {
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error>
    func getSimilarTvShows(tvShowId: Int, page: Int) -> AnyPublisher<SimilarTitlesPage, Error>
    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<[TvShowSeasonDetailModel], Error>
    func getTvShowBackdrop(tvId: Int) -> AnyPublisher<[ImageModel], Error>
}

class TvShowInteractor: TvShowUseCase {
    private let repository: TvShowRepositoryProtocol
    
    required init(repository: TvShowRepositoryProtocol) {
        self.repository = repository
    }
    
    
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error> {
        return repository.getTvShow(tvShowId: tvShowId)
    }
    
    func getSimilarTvShows(tvShowId: Int, page: Int) -> AnyPublisher<SimilarTitlesPage, Error> {
        repository.getSimilarTvShows(tvShowId: tvShowId, page: page)
    }

    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<[TvShowSeasonDetailModel], Error> {
        return repository.getTvShowSeasonDetail(tvShowId: tvShowId, seasonNumber: seasonNumber)
    }
    
    func getTvShowBackdrop(tvId: Int) -> AnyPublisher<[ImageModel], Error> {
        return repository.getTvShowBackdrops(tvId: tvId)
    }
}
