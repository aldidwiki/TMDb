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
    func getMovies(page: Int) -> AnyPublisher<[MovieResponseModel], Error>
    func getTrendingMovies() -> AnyPublisher<[MovieResponseModel], Error>
    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieResponseModel], Error>
    func getMovieGenres() -> AnyPublisher<GenreResponse, Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error>
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<ImageResponse, Error>
}

final class MovieDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: MovieDataSource = MovieDataSource()

    private func request<Response: Decodable>(
        _ path: String,
        parameters: Parameters? = nil
    ) -> AnyPublisher<Response, Error> {
        AF.request(API.baseUrl + path, parameters: parameters, headers: API.headers)
            .validate()
            .publishDecodable(type: Response.self)
            .value()
            .mapError { _ in URLError.invalidResponse as Error }
            .eraseToAnyPublisher()
    }
}

extension MovieDataSource: MovieDataSourceProtocol {
    func getMovies(page: Int) -> AnyPublisher<[MovieResponseModel], Error> {
        let param: Parameters = [
            "page" : page
        ]
        
        return Future<[MovieResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/popular") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: MovieResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value.movies))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }

    func getTrendingMovies() -> AnyPublisher<[MovieResponseModel], Error> {
        request("trending/movie/week")
            .map(\MovieResponse.movies)
            .eraseToAnyPublisher()
    }

    func getNowPlayingMovies(page: Int, region: String) -> AnyPublisher<[MovieResponseModel], Error> {
        request("movie/now_playing", parameters: ["page": page, "region": region])
            .map(\MovieResponse.movies)
            .eraseToAnyPublisher()
    }

    func getMovieGenres() -> AnyPublisher<GenreResponse, Error> {
        request("genre/movie/list")
    }
    
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error> {
        let param: Parameters = [
            "append_to_response": "release_dates,credits,external_ids,videos"
        ]
        
        return Future<MovieDetailResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/\(movieId)") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: MovieDetailResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value))
                            case.failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<ImageResponse, Error> {
        return Future<ImageResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/\(movieId)/images") {
                AF.request(url, headers: API.headers)
                    .validate()
                    .responseDecodable(of: ImageResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
