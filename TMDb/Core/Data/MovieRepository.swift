//
//  TMDbRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol MovieRepositoryProtocol {
    func getMovies(page: Int) -> AnyPublisher<[MovieModel], Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error>
    func searchMovie(query: String, page: Int) -> AnyPublisher<[MovieModel], Error>
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error>
}

final class MovieRepository: NSObject {
    typealias MovieRepositoryInstance = (MovieDataSource) -> MovieRepository
    
    fileprivate let movieDataSource: MovieDataSource
    
    private init(movieDataSource: MovieDataSource) {
        self.movieDataSource = movieDataSource
    }
    
    static let sharedInstance: MovieRepositoryInstance = { movieDataSource in
        return MovieRepository(movieDataSource: movieDataSource)
    }
}

extension MovieRepository: MovieRepositoryProtocol {
    func getMovies(page: Int) -> AnyPublisher<[MovieModel], Error> {
        return self.movieDataSource.getMovies(page: page)
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
    
    func searchMovie(query: String, page: Int) -> AnyPublisher<[MovieModel], Error> {
        return self.movieDataSource.searchMovie(query: query, page: page)
            .map {
                Mapper.mapMovieResponseModelsToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error> {
        return self.movieDataSource.getMovieBackdrops(movieId: movieId)
            .map {
                Mapper.mapImageResponseToImageDomains(input: $0)
            }.eraseToAnyPublisher()
    }
}
