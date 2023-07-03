//
//  TvShowInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation
import Combine

protocol TvShowUseCase {
    func getTvShows() -> AnyPublisher<[TvShowModel], Error>
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error>
}

class TvShowInteractor: TvShowUseCase {
    private let repository: TMDbRepositoryProtocol
    
    required init(repository: TMDbRepositoryProtocol) {
        self.repository = repository
    }
    
    func getTvShows() -> AnyPublisher<[TvShowModel], Error> {
        return repository.getTvShows()
    }
    
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error> {
        return repository.searchTvShows(query: query)
    }
}
