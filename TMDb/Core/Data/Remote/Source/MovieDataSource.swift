//
//  MovieDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Alamofire
import Combine

protocol MovieDataSourceProtocol {
    func getTrendingMovies() -> AnyPublisher<[MovieResponseModel], Error>
    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieResponseModel], Error>
    func getMovieGenres() -> AnyPublisher<GenreResponse, Error>
    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<MovieResponse, Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error>
    func getSimilarMovies(movieId: Int, page: Int) -> AnyPublisher<MovieResponse, Error>
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<ImageResponse, Error>
}

final class MovieDataSource: NSObject {
    private override init() {}

    static let sharedInstance: MovieDataSource = MovieDataSource()
}

extension MovieDataSource: MovieDataSourceProtocol {
    func getTrendingMovies() -> AnyPublisher<[MovieResponseModel], Error> {
        TMDbRequest.value("trending/movie/week")
            .map(\MovieResponse.movies)
            .eraseToAnyPublisher()
    }

    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieResponseModel], Error> {
        TMDbRequest.value("movie/now_playing", parameters: ["page": page, "region": region])
            .map(\MovieResponse.movies)
            .eraseToAnyPublisher()
    }

    func getMovieGenres() -> AnyPublisher<GenreResponse, Error> {
        TMDbRequest.value("genre/movie/list")
    }

    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<MovieResponse, Error> {
        var parameters: Parameters = [
            "with_genres": query.genreID,
            "sort_by": query.sortBy,
            "region": query.region,
            "page": query.page,
            "include_adult": false
        ]
        if let dates = query.releaseYear?.dates {
            parameters["release_date.gte"] = dates.lowerBound
            parameters["release_date.lte"] = dates.upperBound
        }
        if let rating = query.minimumRating {
            parameters["vote_average.gte"] = rating
        }
        return TMDbRequest.value("discover/movie", parameters: parameters)
    }

    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error> {
        TMDbRequest.value("movie/\(movieId)", parameters: ["append_to_response": "release_dates,credits,external_ids,videos"])
    }

    func getSimilarMovies(movieId: Int, page: Int) -> AnyPublisher<MovieResponse, Error> {
        TMDbRequest.value("movie/\(movieId)/similar", parameters: ["page": page])
    }

    func getMovieBackdrops(movieId: Int) -> AnyPublisher<ImageResponse, Error> {
        TMDbRequest.value("movie/\(movieId)/images")
    }
}
