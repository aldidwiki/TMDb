//
//  FavoriteInteractor.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Combine

protocol FavoriteUseCase: AnyObject {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never>
    func getMoviesFavorite() -> AnyPublisher<[FavoriteModel], Error>
}

class FavoriteInteractor: FavoriteUseCase {
    private let favoriteRepository: FavoriteRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol) {
        self.favoriteRepository = favoriteRepository
    }
    
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never> {
        return favoriteRepository.addToFavorite(requestModel)
    }
    
    func getMoviesFavorite() -> AnyPublisher<[FavoriteModel], any Error> {
        return favoriteRepository.getMoviesFavorite()
            .map { response in
                response.movies.map { responseModel in
                    FavoriteModel(
                        id: responseModel.id,
                        title: responseModel.title,
                        posterPath: responseModel.posterPath ?? "",
                        rating: responseModel.rating ?? 0.0,
                        releaseDate: responseModel.releaseDate ?? "",
                        mediaType: Constants.movieType
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
