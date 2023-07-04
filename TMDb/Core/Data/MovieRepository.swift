//
//  TMDbRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol MovieRepositoryProtocol {
    func getMovies() -> AnyPublisher<[MovieModel], Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error>
    func searchMovie(query: String) -> AnyPublisher<[MovieModel], Error>
    
    func getTvShows() -> AnyPublisher<[TvShowModel], Error>
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error>
    
    func addFavorite(from movie: MovieDetailModel) -> AnyPublisher<Bool, Error>
    func getFavorites() -> AnyPublisher<[MovieModel], Error>
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

final class MovieRepository: NSObject {
    typealias MovieRepositoryInstance = (MovieDataSource, LocaleDataSource) -> MovieRepository
    
    fileprivate let movieDataSource: MovieDataSource
    fileprivate let locale: LocaleDataSource
    
    private init(movieDataSource: MovieDataSource, locale: LocaleDataSource) {
        self.movieDataSource = movieDataSource
        self.locale = locale
    }
    
    static let sharedInstance: MovieRepositoryInstance = { movieDataSource, locale in
        return MovieRepository(movieDataSource: movieDataSource, locale: locale)
    }
}

extension MovieRepository: MovieRepositoryProtocol {
    func getMovies() -> AnyPublisher<[MovieModel], Error> {
        return self.movieDataSource.getMovies()
            .map {
                Mapper.mapMovieResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error> {
        return self.movieDataSource.getMovie(movieId: movieId)
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
        return self.movieDataSource.searchMovie(query: query)
            .map {
                Mapper.mapMovieResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getTvShows() -> AnyPublisher<[TvShowModel], Error> {
        return self.movieDataSource.getTvShows()
            .map {
                Mapper.mapTvResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func searchTvShows(query: String) -> AnyPublisher<[TvShowModel], Error> {
        return self.movieDataSource.searchTvShow(query: query)
            .map {
                Mapper.mapTvResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
}
