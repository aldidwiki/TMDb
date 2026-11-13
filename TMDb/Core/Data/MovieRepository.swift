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
    func getTrendingMovies() -> AnyPublisher<[MovieModel], Error>
    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieModel], Error>
    func getMovieGenres() -> AnyPublisher<[GenreModel], Error>
    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<GenreMoviePage, Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error>
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

    func getTrendingMovies() -> AnyPublisher<[MovieModel], Error> {
        movieDataSource.getTrendingMovies()
            .map(Mapper.mapMovieResponseModelsToDomains)
            .eraseToAnyPublisher()
    }

    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieModel], Error> {
        movieDataSource.getNowPlayingMovies(page: page, region: region)
            .map(Mapper.mapMovieResponseModelsToDomains)
            .eraseToAnyPublisher()
    }

    func getMovieGenres() -> AnyPublisher<[GenreModel], Error> {
        movieDataSource.getMovieGenres()
            .map(Mapper.mapGenreResponseToDomains)
            .eraseToAnyPublisher()
    }

    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<GenreMoviePage, Error> {
        movieDataSource.discoverMovies(query: query)
            .map { response in
                GenreMoviePage(
                    movies: Mapper.mapMovieResponseModelsToDomains(input: response.movies),
                    totalPages: response.totalPages ?? 1,
                    totalResults: response.totalResults ?? 0
                )
            }
            .eraseToAnyPublisher()
    }
    
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error> {
        return self.movieDataSource.getMovie(movieId: movieId)
            .map {
                Mapper.mapMovieDetailResponseToDomain(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error> {
        return self.movieDataSource.getMovieBackdrops(movieId: movieId)
            .map {
                Mapper.mapImageResponseToImageDomains(input: $0)
            }.eraseToAnyPublisher()
    }
}
