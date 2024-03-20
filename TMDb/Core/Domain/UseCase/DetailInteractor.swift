//
//  DetailInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol DetailUseCase {
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error>
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error>
}

class DetailInteractor: DetailUseCase {
    private let repository: MovieRepositoryProtocol
    
    required init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error> {
        return repository.getMovie(movieId: movieId)
    }
    
    func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error> {
        return repository.getMovieBackdrops(movieId: movieId)
    }
}
