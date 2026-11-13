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
    func search(query: String, page: Int) -> AnyPublisher<SearchResponse, Error>
}

final class SearchDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: SearchDataSource = SearchDataSource()
}

extension SearchDataSource: SearchDataSourceProtocol {
    func search(query: String, page: Int) -> AnyPublisher<SearchResponse, Error> {
        let param: Parameters = [
            "query": query,
            "page": page
        ]
        
        return AF.request(API.baseUrl + "search/multi", parameters: param, headers: API.headers)
            .validate()
            .publishDecodable(type: SearchResponse.self)
            .value()
            .mapError { _ in URLError.invalidResponse as Error }
            .eraseToAnyPublisher()
    }
}


