//
//  TMDbRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol TMDbRepositoryProtocol {
    func getMovies() -> AnyPublisher<[MovieModel], Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error>
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error>
    func searchMovie(query: String) -> AnyPublisher<[MovieModel], Error>
    
    func addFavorite(from movie: MovieDetailModel) -> AnyPublisher<Bool, Error>
    func getFavorites() -> AnyPublisher<[MovieModel], Error>
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

final class TMDbRepository: NSObject {
    typealias TMDbInstance = (RemoteDataSource, LocaleDataSource) -> TMDbRepository
    
    fileprivate let remote: RemoteDataSource
    fileprivate let locale: LocaleDataSource
    
    private init(remote: RemoteDataSource, locale: LocaleDataSource) {
        self.remote = remote
        self.locale = locale
    }
    
    static let sharedInstance: TMDbInstance = { remoteRepo, localeRepo in
        return TMDbRepository(remote: remoteRepo, locale: localeRepo)
    }
}

extension TMDbRepository: TMDbRepositoryProtocol {
    func getMovies() -> AnyPublisher<[MovieModel], Error> {
        return self.remote.getMovies()
            .map {
                Mapper.mapMovieResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error> {
        return self.remote.getMovie(movieId: movieId)
            .map {
                Mapper.mapMovieDetailResponseToDomain(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func addFavorite(from movie: MovieDetailModel) -> AnyPublisher<Bool, Error> {
        return self.locale.addFavorite(from: Mapper.mapMovieDetailModelToFavoriteEntity(input: movie))
    }
    
    func getFavorites() -> AnyPublisher<[MovieModel], Error> {
        return self.locale.getFavorites().map {
            Mapper.mapFavoriteEntitiesToDomains(input: $0)
        }.eraseToAnyPublisher()
    }
    
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        return self.locale.deleteFavorite(from: movieId)
    }
    
    func searchMovie(query: String) -> AnyPublisher<[MovieModel], Error> {
        return self.remote.searchMovie(query: query)
            .map {
                Mapper.mapMovieResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error> {
        return self.remote.getPerson(personId: personId)
            .map {
                Mapper.mapPersonResponseToDomain(input: $0)
            }.eraseToAnyPublisher()
    }
}
