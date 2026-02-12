//
//  SearchDataSource.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine
import Alamofire

protocol SearchDataSourceProtocol {
    func search(query: String, page: Int) -> AnyPublisher<[SearchResponseModel], Error>
}

final class SearchDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: SearchDataSource = SearchDataSource()
}

extension SearchDataSource: SearchDataSourceProtocol {
    func search(query: String, page: Int) -> AnyPublisher<[SearchResponseModel], any Error> {
        let param: Parameters = [
            "query": query,
            "page": page
        ]
        
        guard let url = URL(string: API.baseUrl + "search/multi") else { return Empty().eraseToAnyPublisher() }
        
        return Future<[SearchResponseModel], Error> { completion in
            AF.request(url, parameters: param, headers: API.headers)
                .validate()
                .responseDecodable(of: SearchResponse.self) { response in
                    switch response.result {
                    case .success(let value):
                        guard let results = value.searchResults else { return completion(.success([])) }
                        completion(.success(results))
                    case .failure:
                        completion(.failure(URLError.invalidResponse))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}


