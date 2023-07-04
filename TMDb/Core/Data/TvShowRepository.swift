//
//  TvShowRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine

protocol TvShowRepositoryProtocol {
    func getTvShows() -> AnyPublisher<[TvShowModel], Error>
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error>
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error>
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
    func getTvShows() -> AnyPublisher<[TvShowModel], Error> {
        return self.tvShowDataSource.getTvShows()
            .map {
                Mapper.mapTvResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error> {
        return self.tvShowDataSource.searchTvShow(query: query)
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
}
