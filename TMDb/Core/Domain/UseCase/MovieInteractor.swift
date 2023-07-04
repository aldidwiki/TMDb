//
//  MovieInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol MovieUseCase {
    func getMovies() -> AnyPublisher<[MovieModel], Error>
    func searchMovies(query: String) -> AnyPublisher<[MovieModel], Error>
}

class MovieInteractor: MovieUseCase {
    private let repository: TMDbRepositoryProtocol
    
    required init(repository: TMDbRepositoryProtocol) {
        self.repository = repository
    }
    
    func getMovies() -> AnyPublisher<[MovieModel], Error> {
        return repository.getMovies()
    }
    
    func searchMovies(query: String) -> AnyPublisher<[MovieModel], Error> {
        return repository.searchMovie(query: query)
    }
}
