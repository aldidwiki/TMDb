//
//  FavoriteRepository.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Combine

protocol FavoriteRepositoryProtocol {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never>
    func getMoviesFavorite() -> AnyPublisher<MovieResponse, Error>
}

final class FavoriteRepository: NSObject {
    typealias FavoriteRepositoryInstance = (FavoriteDataSource) -> FavoriteRepository
    
    fileprivate let favoriteDataSource: FavoriteDataSource
    
    init(favoriteDataSource: FavoriteDataSource) {
        self.favoriteDataSource = favoriteDataSource
    }
    
    static let sharedInstance: FavoriteRepositoryInstance = { dataSource in
        return .init(favoriteDataSource: dataSource)
    }
}

extension FavoriteRepository: FavoriteRepositoryProtocol {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never> {
        return favoriteDataSource.addToFavorite(requestModel)
    }
    
    func getMoviesFavorite() -> AnyPublisher<MovieResponse, any Error> {
        return favoriteDataSource.getMoviesFavorite()
    }
}
