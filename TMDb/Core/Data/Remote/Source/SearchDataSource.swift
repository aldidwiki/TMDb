//
//  SearchDataSource.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine

protocol SearchDataSourceProtocol {
    func search(query: String, page: Int) -> AnyPublisher<SearchResponse, Error>
}

final class SearchDataSource: NSObject {
    private override init() {}

    static let sharedInstance: SearchDataSource = SearchDataSource()
}

extension SearchDataSource: SearchDataSourceProtocol {
    func search(query: String, page: Int) -> AnyPublisher<SearchResponse, Error> {
        TMDbRequest.value("search/multi", parameters: ["query": query, "page": page])
    }
}
