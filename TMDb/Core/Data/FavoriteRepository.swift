//
//  FavoriteRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 07/07/23.
//

import Foundation
import Combine

protocol FavoriteRepositoryProtocol {
    func addFavorite(for favoriteEntity: FavoriteEntity) -> AnyPublisher<Bool, Error>
    func getFavorites() -> AnyPublisher<[FavoriteEntity], Error>
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error>
}

final class FavoriteRepository: NSObject {
    typealias FavoriteRepositoryInstance = (LocaleDataSource) -> FavoriteRepository
    
    fileprivate let localDataSource: LocaleDataSource
    
    private init(localeDataSource: LocaleDataSource) {
        self.localDataSource = localeDataSource
    }
    
    static let sharedInstance: FavoriteRepositoryInstance = { localDataSource in
         return FavoriteRepository(localeDataSource: localDataSource)
    }
}

extension FavoriteRepository: FavoriteRepositoryProtocol {
    func addFavorite(for favoriteEntity: FavoriteEntity) -> AnyPublisher<Bool, Error> {
        return self.localDataSource.addFavorite(from: favoriteEntity)
    }
    
    func getFavorites() -> AnyPublisher<[FavoriteEntity], Error> {
        return self.localDataSource.getFavorites()
    }
    
    func deleteFavorite(movieId: Int) -> AnyPublisher<Bool, Error> {
        return self.localDataSource.deleteFavorite(from: movieId)
    }
}
