//
//  SearchInteractor.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine

protocol SearchUseCase {
    func search(query: String, page: Int) -> AnyPublisher<[SearchModel], Error>
}

class SearchInteractor: SearchUseCase {
    private let searchRepository: SearchRepositoryProtocol
    
    init(searchRepository: SearchRepositoryProtocol) {
        self.searchRepository = searchRepository
    }
    
    func search(query: String, page: Int) -> AnyPublisher<[SearchModel], any Error> {
        return searchRepository.search(query: query, page: page)
    }
}
