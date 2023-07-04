//
//  TvShowDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Alamofire
import Combine

protocol TvShowDataSourceProtocol {
    func getTvShows() -> AnyPublisher<[TvResponseModel], Error>
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailResponse, Error>
    func searchTvShow(query: String) -> AnyPublisher<[TvResponseModel], Error>
}

final class TvShowDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: TvShowDataSource = TvShowDataSource()
}

extension TvShowDataSource: TvShowDataSourceProtocol {
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
    
    func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailResponse, Error> {
        let param: Parameters = [
            "append_to_response": "content_ratings,videos,credits"
        ]
        
        return Future<TvShowDetailResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)/tv/\(tvShowId)") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: TvShowDetailResponse.self) { response in
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
