//
//  SearchRepository.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine

protocol SearchRepositoryProtocol {
    func search(query: String, page: Int) -> AnyPublisher<[SearchModel], Error>
}

final class SearchRepository: NSObject {
    typealias SearchRepositoryInstance = (SearchDataSource) -> SearchRepository
    
    fileprivate let searchDataSource: SearchDataSource
    
    init(searchDataSource: SearchDataSource) {
        self.searchDataSource = searchDataSource
    }

    static let sharedInstance: SearchRepositoryInstance = { searchDataSource in
        return SearchRepository(searchDataSource: searchDataSource)
    }
}

extension SearchRepository: SearchRepositoryProtocol {
    func search(query: String, page: Int) -> AnyPublisher<[SearchModel], any Error> {
        return searchDataSource.search(query: query, page: page)
            .map { response in
                Mapper.mapSearchResponseModelToDomains(input: response)
            }
            .eraseToAnyPublisher()
    }
}
