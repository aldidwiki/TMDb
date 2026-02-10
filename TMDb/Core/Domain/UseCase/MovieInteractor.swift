//
//  MovieInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol MovieUseCase {
    func getMovies(page: Int) -> AnyPublisher<[MovieModel], Error>
    func searchMovies(query: String, page: Int) -> AnyPublisher<[MovieModel], Error>
}

class MovieInteractor: MovieUseCase {
    private let repository: MovieRepositoryProtocol
    
    required init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func getMovies(page: Int) -> AnyPublisher<[MovieModel], Error> {
        return repository.getMovies(page: page)
    }
    
    func searchMovies(query: String, page: Int) -> AnyPublisher<[MovieModel], Error> {
        return repository.searchMovie(query: query, page: page)
    }
}
