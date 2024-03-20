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
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error>
}

class MovieInteractor: MovieUseCase {
    private let repository: MovieRepositoryProtocol
    
    required init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func getMovies() -> AnyPublisher<[MovieModel], Error> {
        return repository.getMovies()
    }
    
    func searchMovies(query: String) -> AnyPublisher<[MovieModel], Error> {
        return repository.searchMovie(query: query)
    }
    
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error> {
        return repository.getMovieBackdrops(movieId: movieId)
    }
}
