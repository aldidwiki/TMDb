//
//  FavoriteDataSource.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Alamofire
import Combine

protocol FavoriteDataSourceProtocol: AnyObject {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never>
    func getMoviesFavorite() -> AnyPublisher<MovieResponse, Error>
    func getTvsFavorite() -> AnyPublisher<TvResponse, Error>
}

final class FavoriteDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance = FavoriteDataSource()
}

extension FavoriteDataSource: FavoriteDataSourceProtocol {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never> {
        guard let url = URL(string: API.baseUrl + "account/\(API.accountId)/favorite") else {
            return Empty<Bool, Never>().eraseToAnyPublisher()
        }
        
        return Future<Bool, Never> { promise in
            AF.request(
                url,
                method: .post,
                parameters: requestModel,
                encoder: JSONParameterEncoder.default,
                headers: API.headers
            )
            .responseDecodable(of: FavoriteResponse.self) { response in
                if case .success(let value) = response.result {
                    promise(.success(value.success))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getMoviesFavorite() -> AnyPublisher<MovieResponse, any Error> {
        guard let url = URL(string: API.baseUrl + "account/\(API.accountId)/favorite/movies") else {
            return Empty<MovieResponse, Error>().eraseToAnyPublisher()
        }
        
        return Future<MovieResponse, Error> { promise in
            AF.request(
                url,
                headers: API.headers
            )
            .responseDecodable(of: MovieResponse.self) { response in
                switch response.result {
                case .success(let value):
                    promise(.success(value))
                case .failure:
                    promise(.failure(URLError.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getTvsFavorite() -> AnyPublisher<TvResponse, any Error> {
        guard let url = URL(string: API.baseUrl + "account/\(API.accountId)/favorite/tv") else {
            return Empty<TvResponse, Error>().eraseToAnyPublisher()
        }
        
        return Future<TvResponse, Error> { promise in
            AF.request(
                url,
                headers: API.headers
            )
            .responseDecodable(of: TvResponse.self) { response in
                switch response.result {
                case .success(let value):
                    promise(.success(value))
                case .failure:
                    promise(.failure(URLError.invalidResponse))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
