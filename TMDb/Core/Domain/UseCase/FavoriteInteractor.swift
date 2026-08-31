//
//  FavoriteInteractor.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Combine

protocol FavoriteUseCase: AnyObject {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<String, Error>
}

class FavoriteInteractor: FavoriteUseCase {
    private let favoriteRepository: FavoriteRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol) {
        self.favoriteRepository = favoriteRepository
    }
    
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<String, any Error> {
        return favoriteRepository.addToFavorite(requestModel)
    }
}
