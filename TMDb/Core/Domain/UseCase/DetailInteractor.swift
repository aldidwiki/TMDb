//
//  DetailInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Combine

protocol DetailUseCase {
    func getMovie() -> AnyPublisher<MovieDetailModel, Error>
}

class DetailInteractor: DetailUseCase {
    private let repository: TMDbRepositoryProtocol
    private let movieId: Int
    
    required init(repository: TMDbRepositoryProtocol, movieId: Int) {
        self.repository = repository
        self.movieId = movieId
    }
    
    func getMovie() -> AnyPublisher<MovieDetailModel, Error> {
        return repository.getMovie(movieId: self.movieId)
    }
}
