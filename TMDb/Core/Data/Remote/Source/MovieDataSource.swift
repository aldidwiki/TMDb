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
    func getMovies() -> AnyPublisher<[MovieResponseModel], Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error>
    func searchMovie(query: String) -> AnyPublisher<[MovieResponseModel], Error>
    
    func getTvShows() -> AnyPublisher<[TvResponseModel], Error>
    func searchTvShow(query: String) -> AnyPublisher<[TvResponseModel], Error>
}

final class MovieDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: MovieDataSource = MovieDataSource()
}

extension MovieDataSource: MovieDataSourceProtocol {
    func getMovies() -> AnyPublisher<[MovieResponseModel], Error> {
        return Future<[MovieResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/popular") {
                AF.request(url, headers: API.headers)
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
    
    func searchMovie(query: String) -> AnyPublisher<[MovieResponseModel], Error> {
        let param: Parameters = [
            "query": query
        ]
        
        return Future<[MovieResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)search/movie") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: MovieResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value.movies))
                            case . failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    func getTvShows() -> AnyPublisher<[TvResponseModel], Error> {
        return Future<[TvResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)tv/popular") {
                AF.request(url, headers: API.headers)
                    .validate()
                    .responseDecodable(of: TvResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value.tvShows))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    func searchTvShow(query: String) -> AnyPublisher<[TvResponseModel], Error> {
        let param: Parameters = [
            "query": query
        ]
        
        return Future<[TvResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)/search/tv") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: TvResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value.tvShows))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
