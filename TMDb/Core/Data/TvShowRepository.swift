//
//  TvShowRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine

protocol TvShowRepositoryProtocol {
    func getTvShows(page: Int) -> AnyPublisher<[TvShowModel], Error>
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error>
    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<[TvShowSeasonDetailModel], Error>
    func getTvShowBackdrops(tvId: Int) -> AnyPublisher<[ImageModel], Error>
}

final class TvShowRepository: NSObject {
    typealias TvShowRepositoryInstance = (TvShowDataSource) -> TvShowRepository
    
    fileprivate let tvShowDataSource: TvShowDataSource
    
    private init(tvShowDataSource: TvShowDataSource) {
        self.tvShowDataSource = tvShowDataSource
    }
    
    static let sharedInstance: TvShowRepositoryInstance = { tvShowDataSource in
        return TvShowRepository(tvShowDataSource: tvShowDataSource)
    }
}

extension TvShowRepository: TvShowRepositoryProtocol {
    func getTvShows(page: Int) -> AnyPublisher<[TvShowModel], Error> {
        return self.tvShowDataSource.getTvShows(page: page)
            .map {
                Mapper.mapTvResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error> {
        return self.tvShowDataSource.getTvShow(tvShowId: tvShowId)
            .map {
                Mapper.mapTvShowDetailResponseToDomain(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<[TvShowSeasonDetailModel], Error> {
        return self.tvShowDataSource.getTvShowSeasonDetail(tvShowId: tvShowId, seasonNumber: seasonNumber)
            .map {
                Mapper.mapTvShowSeasonDetailResponseToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getTvShowBackdrops(tvId: Int) -> AnyPublisher<[ImageModel], Error> {
        return self.tvShowDataSource.getTvShowBackdrops(tvId: tvId)
            .map {
                Mapper.mapImageResponseToImageDomains(input: $0)
            }.eraseToAnyPublisher()
    }
}
