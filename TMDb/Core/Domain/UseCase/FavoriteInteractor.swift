//
//  FavoriteInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import Foundation
import Combine

protocol FavoriteUseCase {
    func getFavorites() -> AnyPublisher<[MovieModel], Error>
    func addFavorite(movie: MovieDetailModel) -> AnyPublisher<Bool, Error>
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

class FavoriteInteractor: FavoriteUseCase {
    private let repository: FavoriteRepositoryProtocol
    
    required init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }
    
    func getFavorites() -> AnyPublisher<[MovieModel], Error> {
        return repository.getFavorites()
    }
    
    func addFavorite(movie: MovieDetailModel) -> AnyPublisher<Bool, Error> {
        return repository.addFavorite(for: Mapper.mapMovieDetailModelToFavoriteEntity(input: movie))
    }
    
    func addFavorite(tvShow: TvShowDetailModel) -> AnyPublisher<Bool, Error> {
        return repository.addFavorite(for: Mapper.mapTvShowDetailModelToFavoriteEntity(input: tvShow))
    }
    
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        return repository.deleteFavorite(movieId: movieId)
    }
}
