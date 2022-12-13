//
//  RemoteDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import CorePackage
import Alamofire
import Combine
import Foundation

protocol RemoteDataSourceProtocol {
    func getMovies() -> AnyPublisher<[MovieResponseModel], Error>
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailResponse, Error>
    func searchMovie(query: String) -> AnyPublisher<[MovieResponseModel], Error>
}

final class RemoteDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: RemoteDataSource = RemoteDataSource()
}

extension RemoteDataSource: RemoteDataSourceProtocol {
    func getMovies() -> AnyPublisher<[MovieResponseModel], Error> {
        return Future<[MovieResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/popular?api_key=150ef4d7b4d3c9953518a6e2ed49928e") {
                AF.request(url)
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
        return Future<MovieDetailResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)movie/\(movieId)?api_key=150ef4d7b4d3c9953518a6e2ed49928e") {
                AF.request(url)
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
            "api_key": "150ef4d7b4d3c9953518a6e2ed49928e",
            "query": query
        ]
        
        return Future<[MovieResponseModel], Error> { completion in
            if let url = URL(string: "\(API.baseUrl)search/movie") {
                AF.request(url, parameters: param)
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
}
